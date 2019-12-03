---
title: "Usefull Monitoring Commands"
slug: "usefull-monitoring-commands"
date: 2019-07-24T11:15:25+08:00
lastmod: 2019-07-24T11:15:25+08:00
draft: true
keywords: []
description: ""
tags: []
categories: ["linux"]
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

## Manipulate Text Output

```bash
# preparation
# create a text with 100 lines:
seq 1 100 | awk '{print $1";"rand()}' > test.txt

# view output using scroll bar
cat test.txt | less

# view line 10 ~ 15 of output
cat test.txt | sed -n "10, 15 p"

# sort output line
cat test.txt | sort -rk 2

```

## Process, CPU and Memory

### Sort Processes by Memory Usage

`ps aux | sort -rnk 4 | head -n 10`

sort by memory usage

### Sort Processes by CPU Usage

`ps aux | sort -nk 3 | head -n 10`


## Reference

- [Most Useful Linux Command Line Tricks - DZone DevOps](https://dzone.com/articles/most-useful-linux-command-line-tricks)
