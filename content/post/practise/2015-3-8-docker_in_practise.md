---
title: "Docker入门实践小结"
description: ""
categories: ["docker"]
tags: ["docker"]
date: 2015-03-08T09:00:00+08:00
slug: "docker-in-practice"
aliases:
  - /docker/docker_in_practise-note
  - /docker/docker_in_practise-note.html
---
[Docker](https://www.docker.com/)是近来大热的技术，似乎没有用过Docker都要落伍了，于是我也在一个个人的项目中用上了Docker，也算有了一些实践经验，与大家分享交流一下。

首先是安装和配置本地的Docker环境，因为Docker是Linux容器引擎，所以宿主机必须是Linux，Windows和Mac系统使用Docker必须先安装Boot2Docker运行一个包含Docker依赖的最小化Linux虚拟机作为宿主机，当然也可以用虚拟机运行一个完整Linux桌面系统然后再在里面安装Docker，个人更推荐后面一种方法。

国内连Docker Hub Pull镜像速度比较慢，推荐使用注册免费使用[DaoCloud](http://www.daocloud.io)的个人加速链接，注册后还可以有Boot2Docker的加速下载链接。
<!-- more -->

如果你想在服务器上运行Docker但是自己没有服务器，推荐使用DigitalOcean的旧金山的VPS，[注册教程](http://www.zhujiceping.com/3469.html), 欢迎使用我的[推广链接](http://www.digitalocean.com/?refcode=40d439332dc3)注册，注册后你可以获得10美元，相当于可以免费使用最小容量的Droplet两个月，如果你消费了25美元，我也可以获得25美元。

有了环境，如果你想系统学习Docker，可以参考下面的书和系列文章。

1. [第一本Docker书 (豆瓣)](http://book.douban.com/subject/26285268/)
2. [Docker 技术入门与实战 (豆瓣)](http://book.douban.com/subject/26284823/) [在线阅读](http://dockerpool.com/static/books/docker_practice/index.html)
3. [深入浅出Docker系列](http://www.infoq.com/cn/articles/docker-core-technology-preview)

使用Docker时尽量使用Dockerfile构建镜像，为Dockerfile创建一个GitHub Repository，然后使用[Docker Hub](https://hub.docker.com/)关联到这个GitHub Repository，就可以自动构建镜像了，每次有提交都会触发自动构建。大的Dockerfile修改提交到Github前最好本地演练一下，避免自动构建失败。国内网络本地运行Docker镜像安装依赖程序比较慢，可以使用国内的镜像软件源，例如如果是ubuntu可以运行下面命令。

```
sed 's/archive\.ubuntu\.com/mirrors\.zju\.edu\.cn/' -i /etc/apt/sources.list
```

Dockerfile的一些细节可以参考官方的Dockerfile，例如[redis Dockerfile](https://github.com/docker-library/redis/blob/062335e0a8d20cab2041f25dfff2fbaf58544471/2.8/Dockerfile)

尽量一个容器（镜像）只负责运行一个应用程序，多个容器可以使用[Fig](http://www.fig.sh/)进行简单编配。例如本人的[CoolCantonese](https://github.com/kk17/CoolCantonese)项目，使用3个容器分别运行python、redis和nginx。

fig.xml:

```
wechat:
  image: kk17/coolcantonese
  entrypoint: python
  command: wechat.py
  ports:
    - "80:8888"
  volumes:
    - .:/Cantonese
    - /Cantonese_audio
  links:
    - redis

redis:
  image: redis

nginx:
  image: nginx
  volumes_from:
    - wechat
  volumes:
    - configs/nginx.conf:/etc/nginx/nginx.conf:ro
  ports:
    - "9090:9090"
```

以上就是本人对Docker的一些基础实践，欢迎多交流。




