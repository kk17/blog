---
title: "Use Spark Sql With Hive Metastore"
slug: "use-spark-sql-with-hive-metastore"
date: 2019-02-27T15:52:48+08:00
lastmod: 2019-02-27T15:52:48+08:00
draft: false
keywords: ["spark-sql", "hive", "metastore", "thrift-server"]
description: ""
tags: ["spark", "spark-sql", "hive", "metastore", "thrift-server"]
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

# Spark SQL

Spark SQL is a module for working with structured data

```python
spark = SparkSession.builder.config(conf=conf).enableHiveSupport().getOrCreate()
spark.sql("use database_name")
spark.sql("select * from table_name where id in (3085,3086,3087) and dt > '2019-03-10'").toPandas()
```

## Hive

Data warehouse software for reading, writing, and managing large datasets residing in distributed storage and queried using SQL syntax.

Hive transforms SQL queries as Hive MapReduce job.

Besides MapReduce, Hive can use Spark and Tez as execute engine.

## Spark and Hive

In Spark 1.0, Spark use many Hive codes in Spark SQL. It ran Hadoop style Map/Reduce jobs on top of the Spark engine

There is almost no Hive left in Spark 2.0. While the Sql Thrift Server is still built on the HiveServer2 code, almost all of the internals are now completely Spark-native, for example Spark it build a brand new Spark-native optimization engine knows as Catalyst.

## HiveServer2

A server interface that enables remote clients to execute queries against Hive and retrieve the results.

With HiveServer2, we can use JDBC and ODBC connecters to connect to Hive.

## Spark Thrift Server

Spark Thrift Server is variant of HiveServer2.

Thrift is the RPC framework use for client and Server communication.

![https://user-images.githubusercontent.com/22542670/27733176-54b684c2-5db2-11e7-946b-5b5ef5595e43.png](https://user-images.githubusercontent.com/22542670/27733176-54b684c2-5db2-11e7-946b-5b5ef5595e43.png)

Spark Thrift Server have a bug in showing db schemes and tables. We cherry-picked the patch codes into Spark 2.3.2 the version we now used and used a shaded jar in deploying Spark Thrift Server.

[[SPARK-24196] Spark Thrift Server - SQL Client connections does't show db artefacts - ASF JIRA](https://issues.apache.org/jira/browse/SPARK-24196)

#### “Inception” or “Multiple Sessions”

From Spark 1.6, by default, the Thrift server runs in multi-session mode

```
spark.sql.hive.thriftServer.singleSession=false
```

#### “Mysterious OOMs and How to Avoid Them” or “Incremental Collect”

```
spark.sql.thriftServer.incrementalCollect=false
```

The setting IncrementalCollect changes the gather method from collect to toLocalIterator.

## Metastore

Central repository of Hive metadata.

![https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.5/bk_spark-component-guide/content/figures/4/figures/sts-architecture.png](https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.5/bk_spark-component-guide/content/figures/4/figures/sts-architecture.png)

_Metastore need a warehouse location for storage for internal tables data. Although we only use external tables, the warehouse location is still needed because every database in Metastore needs a corresponding folder in the warehouse. Spark references `spark.sql.warehouse.dir` as the default Spark SQL Hive Warehouse location. In EMR cluster this property is config to cluster HDFS location by default. If the cluster goes down the HDFS will become unavailable and this may cause some problem in using Spark SQL to query table data. Therefore we the location to the local file system. In other words, config `spark.sql.warehouse.dir` to `file:///usr/lib/spark/warehouse` in `spark-defaults.conf`._

## References

[Russell Spitzer's Blog: Spark Thrift Server Basics and a History](http://www.russellspitzer.com/2017/05/19/Spark-Sql-Thriftserver/)
