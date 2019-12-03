---
title: "java内存模型和垃圾回收学习笔记"
description: ""
categories: ["java"]
tags: ["jvm"]
date: 2015-02-01T09:00:00+08:00
slug: "jvm-memory-model-and-gc"
aliases:
  - /java/jvm-memory-model-and-gc
  - /java/jvm-memory-model-and-gc.html
---
## Java（JVM）内存模型
Java内存模型建立在自动内存管理的概念之上。当一个对象不再被一个应用所引用，垃圾回收器就会回收它，从而释放相应的内存。这一点和其他很多需要自行释放内存的语言有很大不同。

JVM从底层操作系统中分配内存，并将它们分为以下几个区域：
![](http://www.pointsoftware.ch/wp-content/uploads/2012/11/Cookbook_JVMArguments_2_MemoryModel.png)

<!-- more -->

![](http://www.pointsoftware.ch/wp-content/uploads/2012/10/JUtH_20121024_RuntimeDataAreas_2_MemoryModel.png)

1. 堆空间（Heap Space）：这是共享的内存区域，用于存储可以被垃圾回收器回收的对象。

2. 方法区（Method Area）：这块区域以前被称作“永生代”（permanent generation），用于存储被加载的类。这块区域最近被JVM取消了。现在，被加载的类作为元数据加载到底层操作系统的本地内存区。

3. 本地区（Native Area）：这个区域用于存储基本类型的引用和变量。


## 堆空间与永久代：
![](http://colobu.com/2014/12/16/java-jvm-memory-model-and-garbage-collection-monitoring-tuning/Java-Memory-Model.png)

### 永久代（Permanent Generation）
永久代或者“Perm Gen”包含了JVM需要的应用元数据，这些元数据描述了在应用里使用的类和方法。注意，永久代不是Java堆内存的一部分。
永久代存放JVM运行时使用的类。永久代同样包含了Java SE库的类和方法。永久代的对象在full GC时进行垃圾收集。

### 堆空间
Java 中的堆是 JVM 所管理的最大的一块内存空间，主要用于存放各种类的实例对象。
在 Java 中，堆被划分成两个不同的区域：新生代 ( Young )、老年代 ( Old )。新生代 ( Young ) 又被划分为三个区域：Eden、From Survivor、To Survivor。
这样划分的目的是为了使 JVM 能够更好的管理堆内存中的对象，包括内存的分配以及回收。

## Java垃圾回收
**所有的垃圾收集都是“Stop the World”事件，因为所有的应用线程都会停下来直到操作完成（所以叫“Stop the World”）。**

因为年轻代里的对象都是一些声明周期很短的（short-lived ）对象，执行Minor GC非常快，所以应用不会受到程序暂停的影响。

由于Major GC会检查所有存活的对象，因此会花费更长的时间。应该尽量减少Major GC。因为Major GC会在垃圾回收期间让你的应用反应迟钝，所以如果你有一个需要快速响应的应用， 在频繁发生Major GC时，你会看到超时错误。

垃圾回收时间取决于垃圾回收策略。这就是为什么有必要去监控垃圾收集和对垃圾收集进行调优。从而避免要求快速响应的应用出现超时错误。

图解垃圾回收过程：
![图解垃圾回收过程](https://plumbr.eu/wp-content/uploads/2015/02/minor-gc-major-gc-full-gc.jpg)

回收算法与Stop the World：
![回收算法与Stop the World](http://apmblog.dynatrace.com/wp-content/600x263xGC-Compare-600x263.png.pagespeed.ic.3rAxdnMHEa.png)

可用的垃圾回收算法选项：
![可用的垃圾回收算法选项](http://www.jdon.com/idea/images/jvm.png)


## Java垃圾收集监控
1. jstat
可以使用jstat命令行工具监控JVM内存和垃圾回收。标准的JDK已经附带了jstat，所以不需要做任何额外的事情就可以得到它

2. Java VisualVM及Visual GC插件
如果你想在GUI里查看内存和GC，那么可以使用jvisualvm工具。Java VisualVM同样是JDK的一部分，所以你不需要单独去下载。

## 相关文章
[JVM必备指南 - ImportNew](http://www.importnew.com/13556.html)  
[JVM内存模型和性能优化 - 解道Jdon](http://www.jdon.com/idea/jvm.html)  
[Java内存与垃圾回收调优 | 鸟窝](http://colobu.com/2014/12/16/java-jvm-memory-model-and-garbage-collection-monitoring-tuning/)  
[Minor GC vs Major GC vs Full GC – Plumbr](https://plumbr.eu/blog/garbage-collection/minor-gc-vs-major-gc-vs-full-gc)  
[Major GCs - Separating Myth from Reality - Dynatrace APM Blog](http://apmblog.dynatrace.com/2011/03/10/major-gcs-separating-myth-from-reality/)  
[Point Software AG](http://www.pointsoftware.ch/de/under-the-hood-runtime-data-areas-javas-memory-model/)  
