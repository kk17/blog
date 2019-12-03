---
title: "linux命令行笔记"
description: ""
categories: ["note"]
tags: ["linux"]
date: 2015-08-19T09:00:00+08:00
slug: "linux-commands"
aliases:
  - /note/linux_commands
  - /note/linux_commands.html
---


## 命令行日常系快捷键
如下的快捷方式非常有用，能够极大的提升你的工作效率：

1. CTRL + A – 移动光标到行首
1. CTRL + E – 移动光标到行末
1. CTRL + U – 剪切光标前的内容
1. CTRL + K – 剪切光标至行末的内容
1. ALT+ ← - 光标跳到上一个单词
1. ALT + → - 光标跳到下一个单词
1. CTRL + ← - 光标跳到上一个单词（mac）
1. CTRL + → - 光标跳到下一个单词(mac)
1. CTRL + R - 搜索命令行历史
1. sudo !! 以root权限运行上一条命令
1. !command 使用上一条命令的参数

## 网络：
查看端口占用情况 
`lsof -i:8087`
`netstat –apn | grep 8080`

查看ip:
`ifconfig`
`ip a`

<!-- more -->

## CPU：
查看CPU核心数
 `cat /proc/cpuinfo |grep -c processor`

`top `然后按Shift+P，按照进程处理器占用率排序(mac下使用 `top -u`或 `top -o cpu`)

## 内存：
用free命令查看内存使用情况
`free -m`

`top` 然后按Shift+M, 按照进程内存占用率排序(mac下使用 `top -o mem`)

查看进程，按内存从大到小排列
`ps -e  -o "%C  : %p : %z : %a"|sort -k5 -nr`

## 磁盘：
查看磁盘使用情况
`df -h`
用iostat查看磁盘/dev/sdc3的磁盘i/o情况，每两秒刷新一次
`iostat -d -x /dev/sdc3 2`

查看磁盘目录统计数据
`du -h`
`du -h -d 1 .`

## 文件查找
在多级目录中查找某个文件的方法
1) `find /dir -name filename.ext `
2) `du -a | grep filename.ext `
3) `locate filename.ext`

## 软件管理
debian&ubuntu：
apt-get也是dpkg的包装，直接使用`dpkg -l` 来查看已经安装了的软件
`dpkg -l | grep '^ii'`
对于Server版， 推荐使用`aptitude`来查看，安装、删除deb包
`sudo apt-get install aptitude`
然后执行 sudo aptitude 进入管理界面即可 ：）

## linux服务器之间相互复制文件
copy 本地文件1.sh到远程192.168.9.10服务器的/data/目录下
`scp /etc/1.sh king@192.168.9.10:/data/ `
copy远程192.168.9.10服务器/data/2.sh文件到本地/data/目录
`scp king@192.168.9.10:/data/2.sh /data/`

## 有用的命令
`date -d @1267619929`


### 一些资源：
- [Linux工具快速教程 — Linux Tools Quick Tutorial](http://linuxtools-rst.readthedocs.org/zh_CN/latest/index.html)
- [10个重要的Linux ps命令实战](http://blog.jobbole.com/83610/)
- [Awk 20 分钟入门介绍](http://blog.jobbole.com/83844/)
- [11个让你吃惊的 Linux 终端命令 - 博客 - 伯乐在线](http://blog.jobbole.com/86948/)
- [提高 Vim 和 Shell 效率的 9 个建议 - 博客 - 伯乐在线](http://blog.jobbole.com/86809/)
- [趣文：有趣的 Linux 命令 - 博客 - 伯乐在线](http://blog.jobbole.com/41129/)
- [你可能不知道的Shell | 酷 壳 - CoolShell.cn](http://coolshell.cn/articles/8619.html)
- [Linux常用的shell命令 – 程序猿](http://www.xprogrammer.com/1799.html)
- [TLCL](http://billie66.github.io/TLCL/index.html)
- [一些命令行效率工具 - 博客 - 伯乐在线](http://blog.jobbole.com/89609/)





