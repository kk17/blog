---
title: "YARN Basics"
slug: "yarn-basics"
date: 2019-07-15T19:31:49+08:00
lastmod: 2019-07-15T19:31:49+08:00
draft: false
keywords: ["YARN"]
description: ""
tags: ["YARN"]
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

[Apache Hadoop YARN](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html) is the cluster manager for Hadoop MapReduce, but it can also be used for other compute framework such as Spark. YARN(Yet Another Resource Negotiator) was introduced since Hadoop 2.0 to split up the functionalities of resource management and job scheduling/monitoring into separate daemons. The idea is to have a global ResourceManager (RM) and per-application ApplicationMaster (AM). An application is either a single job or a DAG of jobs.
<!--more-->

![](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/yarn_architecture.gif)

- **ResourceManager** is the ultimate authority that arbitrates resources among all the applications in the system. There is only one global ResourceManager in a YARN cluster and it has two main components:
  * **Scheduler** is responsible for allocating resources to the various running applications subject to familiar constraints of capacities, queues etc.
  * **ApplicationsManager** is responsible for accepting job-submissions, negotiating the first container for executing the application specific ApplicationMaster and provides the service for restarting the ApplicationMaster container on failure.

- **NodeManager** is the per-machine framework agent who is responsible for containers, monitoring their resource usage (cpu, memory, disk, network) and reporting the same to the ResourceManager/Scheduler.

- **ApplicationMaster** is responsible for negotiating appropriate resource containers from the Scheduler, tracking their status and monitoring for progress. The ApplicationMaster is run per-application.


## Spark On YARN

How Spark executors are started in YARN cluster mode:

![](https://trello-attachments.s3.amazonaws.com/5cc443a11c07cb4a8711dceb/5d1dadb1bce6c77b381e18ef/29b5697eaeeb984f0ca873b8ae1bff74/image.png)

## Reference

- [Apache Hadoop 2.9.2 – Apache Hadoop YARN](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html)
- [Untangling Apache Hadoop YARN, Part 1: Cluster and YARN Basics - Cloudera Engineering Blog](https://blog.cloudera.com/blog/2015/09/untangling-apache-hadoop-yarn-part-1/)
- [Tuning YARN | 5.3.x | Cloudera Documentation](https://www.cloudera.com/documentation/enterprise/5-3-x/topics/cdh_ig_yarn_tuning.html)