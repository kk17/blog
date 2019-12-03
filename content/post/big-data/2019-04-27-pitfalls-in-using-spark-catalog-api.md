---
title: "Pitfalls in Using Spark Catalog API"
slug: "pitfalls-in-using-spark-catalog-api"
date: 2019-04-27T16:42:59+08:00
lastmod: 2019-04-27T16:42:59+08:00
draft: false
keywords: ["spark-sql", "spark-catalog"]
description: ""
tags: ["spark", "spark-sql", "spark-catalog"]
categories: ["big-data"]
author: ""

# You can also close(false) or open(true) something for this content.
# P.S. comment can only be closed
comment: true
toc: true
autoCollapseToc: false
# You can also define another contentCopyright. e.g. contentCopyright: "This is another copyright."
contentCopyright: false
reward: false
mathjax: false
---

Spark SQL supports querying data via SQL and in order to use this feature, we must enable Spark with Hive support, because Spark uses Hive Metastore to store metadata. By default, Spark uses an in-memory embedded database called Derby to store the metadata, but it can also configure to use an external Hive Metastore. Spark Hive Configuration can be found here:  [Hive Tables - Spark 2.4.1 Documentation](https://spark.apache.org/docs/latest/sql-data-sources-hive-tables.html)

Except using DDL SQL to manipulate metadata stored in Hive Metastore, Spark SQL also provides a minimalist API know as Catalog API to manipulate metadata in spark applications. Spark Catalog API can be found here: [Catalog (Spark 2.2.1 JavaDoc)](https://spark.apache.org/docs/2.2.1/api/java/org/apache/spark/sql/catalog/Catalog.html) and [pyspark.sql.catalog — PySpark master documentation](https://spark.apache.org/docs/2.3.0/api/python/_modules/pyspark/sql/catalog.html).

After using Spark Catalog API for a period of time, I found some pitfalls.

<!--more-->

## 1. Problem in creating external table with specified schema

When a user create an external table with specified schema, the schema will actually not be used and the table will fail to be recognized as a partitioned table. I dived into the Spark source code and found the reason. The source code is from Spark 2.3.2.

Source Code is listed below and I omitted some code and added some notes start with `//NOTE:`.

The API where implemented by [CatalogImpl.scala](https://github.com/apache/spark/blob/branch-2.3/sql/core/src/main/scala/org/apache/spark/sql/internal/CatalogImpl.scala#L338)

```scala
override def createTable(  
      tableName: String,  
      source: String,  
      schema: StructType,  
      options: Map[String, String]): DataFrame = {  
    val tableIdent = sparkSession.sessionState.sqlParser.parseTableIdentifier(tableName)  
    val storage = DataSource.buildStorageFormatFromOptions(options)  
    val tableType = if (storage.locationUri.isDefined) {  
      CatalogTableType.EXTERNAL  
    } else {  
      CatalogTableType.MANAGED  
    }  
    //NOTE: user specified schema is set to tableDesc and use no partitionColumnNames can specify here  
    val tableDesc = CatalogTable(  
      identifier = tableIdent,  
      tableType = tableType,  
      storage = storage,  
      schema = schema,   
      provider = Some(source)  
    )  
    val plan = CreateTable(tableDesc, SaveMode.ErrorIfExists, None)  
    sparkSession.sessionState.executePlan(plan).toRdd  
    sparkSession.table(tableIdent)  
  }
```

The Catalog createTable API will eventually run `CreateDataSourceTableCommand` in [createDataSourceTables.scala](https://github.com/apache/spark/blob/branch-2.3/sql/core/src/main/scala/org/apache/spark/sql/execution/command/createDataSourceTables.scala#L80)

```scala
case class CreateDataSourceTableCommand(table: CatalogTable, ignoreIfExists: Boolean)  
  extends RunnableCommand {

  override def run(sparkSession: SparkSession): Seq[Row] = {  
    ...  
    //NOTE: the resolved dataSource include an inferred schema and partitionSchema  
    val dataSource: BaseRelation =  
      DataSource(  
        sparkSession = sparkSession,  
        userSpecifiedSchema = if (table.schema.isEmpty) None else Some(table.schema),  
        partitionColumns = table.partitionColumnNames,  
        className = table.provider.get,  
        bucketSpec = table.bucketSpec,  
        options = table.storage.properties ++ pathOption,  
        // As discussed in SPARK-19583, we don't check if the location is existed  
        catalogTable = Some(tableWithDefaultOptions)).resolveRelation(checkFilesExist = false)

    val partitionColumnNames = if (table.schema.nonEmpty) {  
      //NOTE: if user specified schama, use the partitionColumnNames from CatalogTable passed to the class  
      table.partitionColumnNames  
    } else {  
      ...  
    }

    val newTable = dataSource match {  
      case r: HadoopFsRelation if r.overlappedPartCols.nonEmpty =>  
        ...

      case _ => 

        table.copy(  
          schema = dataSource.schema, //NOTE: no matter whether user specify a schema, just use the infered schmea here  
          partitionColumnNames = partitionColumnNames,  
          ...  
          )  
    }  
    ...  
    sessionState.catalog.createTable(newTable, ignoreIfExists = false)

    Seq.empty[Row]  
  }  
}
```

#### Solution

Don't know the reason why the source code is written in that way and whether this should be considered as a bug. One solution we come up with for this problem is to implement a custom crateTable API.

[CatalogUtil.scala](https://gist.github.com/kk17/60f956379398b0792059498543566e2a#file-catalogutil-scala)

```scala
object CatalogUtil {

    lazy val sparkSession = SparkSession.getActiveSession.get  
    ...  
    def createTable(  
                       tableName: String,  
                       source: String,  
                       path: String,  
                       schema: StructType,  
                       options: Map[String, String],  
                       partitionColumnsInSchema: Boolean  
                   ): Unit = {  
        ...

        val table = CatalogTable(  
            identifier = tableIdent,  
            tableType = tableType,  
            storage = storage,  
            schema = schema,  
            provider = Some(newSource)  
        )  
        ...  
        val dataSource: BaseRelation =  
            DataSource(  
                sparkSession = sparkSession,  
                userSpecifiedSchema = if (table.schema.isEmpty) None else Some(table.schema),  
                partitionColumns = table.partitionColumnNames,  
                className = table.provider.get,  
                ...  
                )).resolveRelation(checkFilesExist = false)

        //NOTE: alway use infered partitionColumnNames here, cause we don't allow use specify partitionColumnNames  
        val partitionColumns: Array[StructField] = {  
            assert(table.partitionColumnNames.isEmpty)  
            dataSource match {  
                case r: HadoopFsRelation => r.partitionSchema.fields  
                case _ => Array.empty  
            }  
        }

        val partitionColumnNames = partitionColumns.map(_.name)

        //NOTE: merge partitionColumns into table schema if necessary  
        val newSchema: StructType = if (table.schema.nonEmpty) {  
            if (partitionColumnsInSchema) {  
                table.schema  
            } else {  
                table.schema.fields.map(_.name).intersect(partitionColumnNames) match {  
                    case Array() => StructType(table.schema.fields ++ partitionColumns)  
                    case arr => {  
                        val message = "Partition column names: " +  
                            s"[${arr.mkString(",")}] cannot exist in user specified schema.\n" +  
                            s" Inferred partition columns: [${partitionColumnNames.mkString(",")}].\n" +  
                            s" User specified schema:\n${table.schema.treeString}"

                        throw new ConflictedSchemaException(message)  
                    }  
                }  
            }  
        } else {  
            dataSource.schema  
        }

        val newTable =  
            table.copy(  
                schema = newSchema, //NOTE: use specifed schema  
                partitionColumnNames = partitionColumnNames,  
                ...

  
        sessionState.catalog.createTable(newTable, ignoreIfExists = false)  
    }

}
```

As you see our custom API is written in Scala, if we want to use in a python application, we must use Python Java Gateway. You can find more detail here:[Using Scala code in PySpark applications](https://diogoalexandrefranco.github.io/scala-code-in-pyspark/)

## 2. Partitioned table data only avaliable after invoked `recoverPartitions`

If you created an external partitioned table and immediately read data from the table, you will find the data is empty. Data only available after invoked `recoverPartitions` method. This is different from a non-partitioned table and Spark Catalog doesn't have a convenient method for testing whether the table is partitioned.


```python
class SparkCatalog(Catalog):  
    ...  
    def is_partitioned_table(self, table_name):  
        return "PARTITIONED BY" in self.get_create_table_statement(table_name)

    def get_create_table_statement(self, table_name):  
        return self._sparkSession.sql(f"show create table `{table_name}`").collect()[0]["createtab_stmt"]

    def create_or_refresh_table(...):  
    ...  
                if self.is_partitioned_table(table):  
                    self.recoverPartitions(table)  
    ...
```

## 3. `refreshTable` API only refresh the cache in SparkContext

`catalog.refreshTable` only refresh the cached data and metadata of the given table in sparkContext, if we want to update the table's meta(schema, transient_lastDdlTime and etc) in the hive metastore, we need to drop and recreate the table.
