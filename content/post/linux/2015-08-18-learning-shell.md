---
title: "Shell学习笔记"
description: ""
categories: ["tools"]
tags: ["linux","shell"]
date: 2015-08-18T09:00:00+08:00
lastmod: 2019-04-27T09:00:00+08:00
slug: "learning-shell"
aliases:
  - /tools/learning-shell
  - /tools/learning-shell.html
---

## shebang

```bash
#!/usr/bin/env bash
```

这一行表明，不管用户选择的是那种交互式shell,该脚本需要使用bash shell来运行。由于每种shell的语法大不相同，所以这句非常重要。

## 变量
1. 定义变量

```bash
X="hello"
```
2. 引用变量

```bash
$X
```

3. 单引号 VS 双引号
基本上来说，**变量名会在双引号中展开**，单引号中则不会。如果你不需要引用变量值，那么使用单引号可以很直观的输出你期望的结果。 An example 示例

```bash
#!/usr/bin/env bash
echo -n '$USER=' 
# -n选项表示阻止echo换行
echo "$USER"
echo "\$USER=$USER"  
# 该命令等价于上面的两行命令
```

<!-- more -->

### 注意点
1. 使用双引号来保护变量名

```bash
# !/bin/bash
X=""
if [ -n "$X" ]; then    
# -n 用来检查变量是否非空
         echo "the variable X is not the empty string"
fi
```

2. 使用大括号保护变量

```bash
# !/bin/bash
X=ABC
echo "${X}abc"
```


## 条件语句 if/then/elif/then/fi

```bash
if [[ condition1 ]]; then
    statement1
    statement2
    ..........
elif [[ condition2 ]]; then
    statement3
    statement4
    ........    
else
    statement5
    statement6
    ........    
fi
```

## Test命令与操作符

```bash
[[ operand1 operator operand2 ]]
```
Test命令的格式为“操作数< 空格 >操作符< 空格 >操作数”或者“操作符< 空格 >操作数”，这里特别说明必须要有这些空格，因为shell将没有空格的第一串字符视为一个操作符（以-开头）或者操作数。

### 操作符列表
| 操作符 |               为真条件               | 操作数个数 |
|--------|--------------------------------------|------------|
| -n     | 操作数非0长度                        |          1 |
| -z     | 操作有长度                           |          1 |
| -d     | 存在目录                             |          1 |
| -f     | 存在文件                             |          1 |
| =      | 操作数是字符串并相等                 |          2 |
| !=     | 与=相反                              |          2 |
| -eq    | 操作数是整数并相等                   |          2 |
| -neq   | 与-eq相反                            |          2 |
| -lt    | 操作数是整数并操作数1小于操作数2     |          2 |
| -le    | 操作数是整数并操作数1小于等于操作数2 |          2 |
| -gt    | 操作数是整数并操作数1大于操作数2     |          2 |
| -ge    | 操作数是整数并操作数1大于等于操作数2 |          2 |

## 循环
## For 循环
For循环会遍历空格分开的条目。注意，如果某一项含有空格，必须要用引号引起来，例子如下：

```bash
# !/bin/bash
colour1="red"
colour2="light blue"
colour3="dark green"
for X in "$colour1" $colour2" $colour3"
do
    echo $X
done
```
**在for循环中可以使用通配符**如果shell解析字符串时遇到*号，会将它展开为所有匹配的文件名

## While 循环
当给定条件为真值时，while循环会重复执行。例如：

```bash
# !/bin/bash
X=0
while [[ $X -le 20 ]; do
    echo $X
    X=$((X+1))
done
```

## case语句

```bash
case $key in
    a|b)
    statement1
    ;;
    c)
    statement2
    *)
    break
    # unknown option
    ;;
esac
```

## 命令替换
大括号扩展： $(commands) 会展开为命令commands的输出结果。并且允许嵌套使用，所以commands中允许包含子大括号扩展。
反撇好扩展：将commands扩展为命令commands的输出结果。不允许嵌套。

## 位置参数处理
`$n` n为0开始的整数表示第n个命令行参数，`$0`为命令本身
`$# ` 参数个数
位置参数可以用`shift`命令左移。比如`shift 3`表示原来的`$4`现在变成`$1`，原来的`$5`现在变成`$2`等等，原来的`$1`. `$2`. `$3`丢弃，`$0`不移动。不带参数的`shift`命令相当于`shift 1`。

处理参数例子：

```bash
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -a)
    statement1
    shift
    ;;
    -b)
    statement2
    shift
    ;;
    *)
    break
    # unknown option
    ;;
esac
done
```

## 函数
shell 可以用户定义函数，然后在shell脚本中可以随便调用

```bash
[ function ] funname [()]
{
    action;
    [return int;]
}

sum()
{
    echo $1,$2
    return $(($1+$2))
}
sum 5 7
echo $?
```

1. 定义函数可以与系统命令相同，说明shell搜索命令时候，首先会在当前的shell文件定义好的地方查找，找到直接执行。
2. 需要获得函数值：通过$?获得
3. 如果需要传出其它类型函数值，可以在函数调用之前，定义变量（这个就是全局变量）。在函数内部就可以直接修改，然后在执行函数就可以读出修改过的值。
4. 如果需要定义自己变量，可以在函数中定义：local 变量=值 ，这时变量就是内部变量，它的修改，不会影响函数外部相同变量的值 。


## 一些资源
- [Bash快速入门指南 - 博客 - 伯乐在线](http://blog.jobbole.com/85183/)
- [linux shell 自定义函数(定义. 返回值. 变量作用域- ）介绍 - 程默 - 博客园](http://www.cnblogs.com/chengmo/archive/2010/10/17/1853356.html)
- [Shell编程基础 - Integer - 开源中国社区](http://my.oschina.net/itblog/blog/204410)
- [用 Python 替代 Bash 脚本 - 技术翻译 - 开源中国社区](http://www.oschina.net/translate/python-scripts-replacement-bash-utility-scripts)
