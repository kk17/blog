---
title: "Understand Airflow"
slug: "understand-airflow"
date: 2019-07-24T14:24:49+08:00
lastmod: 2019-07-24T14:24:49+08:00
draft: false
keywords: ["airflow"]
description: "airflow basic"
tags: ["airflow"]
categories: ["big-data"]
author: "Kyle"

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
## Key concepts

For context around the terms used in this blog post, here are a few key concepts for Airflow:

*   **DAG** (Directed Acyclic Graph): a workflow which glues all the tasks with inter-dependencies.
*   **Operator**: a template for a specific type of work to be executed. For example, BashOperator represents how to execute a bash script, while PythonOperator represents how to execute a python function, etc.
*   **Sensor**: a type of special operator which will only execute if a certain condition is met.
*   **Task**: a parameterized instance of an operator/sensor which represents a unit of actual work to be executed.
*   **Plugin**: an extension to allow users to easily extend Airflow with various custom hooks, operators, sensors, macros, and web views.
*   **Pools**: concurrency limit configuration for a set of Airflow tasks.
*   ***Connections*** to define any external DB, FTP etc. connection’s authentication.
*   ***Variables*** to store and retrieve arbitrary content or settings as a simple key value.
*   ***XCom*** to share keys/values between independent tasks.
*   **Pools** to limit the execution parallelism on arbitrary sets of tasks.
*   **Hooks** to reach external platforms and databases.

<!--more-->


![](https://miro.medium.com/max/1400/1*N2CWqwBZiulBUwiPprKg4g.png)

**Figure 3.2 Screenshots from the Airflow UI, Representing the example workflow DAG. Top Subpanel**: The Graph View of the `DagRun` for Jan. 25th. Dark green nodes indicate `TaskInstance`s with “success” states. The light green node depicts a `TaskInstance` in the “running” state. **Bottom Subpanel**: The Tree View of the `example_workflow` DAG. The main components of Airflow are highlighted in screenshot, including Sensors, Operators, Tasks, `DagRuns`, and `TaskInstances`. `DagRuns` are represented as columns in the graph view — the `DagRun` for Jan. 25th is outlined in cyan. Each square in the graph view represents a `TaskInstance` — the `TaskInstance` for the (“running”) `perform_currency_conversion` task on Jan. 25th is outlined in blue.

## Airflow architecture

The following diagram shows the typical components of Airflow architecture.

![](https://d2908q01vomqb2.cloudfront.net/f1f836cb4ea6efb2a0b1b99f41ad8b103eff4b59/2019/04/17/sagemaker-airflow-2.gif)

*   ***Scheduler:*** The scheduler is a persistent service that monitors DAGs and tasks, and triggers the task instances whose dependencies have been met. The scheduler is responsible for invoking the executor defined in the Airflow configuration.
*   ***Executor:*** Executors are the mechanism by which task instances get to run. Airflow by default provides different types of executors, and you can define custom executors, such as a Kubernetes executor.
*   ***Broker:*** The broker queues the messages (task requests to be executed) and acts as a communicator between the executor and the workers.
*   ***Workers:*** The actual nodes where tasks are executed and that return the result of the task.
*   ***Web server:*** A webserver to render the Airflow UI.
*   ***Configuration file:*** Configure settings such as executor to use, Airflow metadata database connections, DAG, and repository location. You can also define concurrency and parallelism limits, etc.
*   ***Metadata database:*** Database to store all the metadata related to the DAGS, DAG runs, tasks, variables, and connections.

## Reference and Further Reading

- [Build end-to-end machine learning workflows with Amazon SageMaker and Apache Airflow | AWS Machine Learning Blog](https://aws.amazon.com/cn/blogs/machine-learning/build-end-to-end-machine-learning-workflows-with-amazon-sagemaker-and-apache-airflow/)
- [Running Apache Airflow At Lyft - Lyft Engineering](https://eng.lyft.com/running-apache-airflow-at-lyft-6e53bb8fccff)
- [Understanding Apache Airflow’s key concepts - Dustin Stansbury - Medium](https://medium.com/@dustinstansbury/understanding-apache-airflows-key-concepts-a96efed52b1a)
