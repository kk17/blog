---
title: "Sublime Text技巧"
description: ""
categories: ["tools"]
tags: ["tools", "sublime-text"]
date: 2015-01-26T09:00:00+08:00
slug: "sublime-text"
aliases:
  - /tools/sublime-text
  - /tools/sublime-text.html
---
本文记录一些Sublime Text的技巧和资源链接。

# 快捷键：
## Goto Anything：
* 用 Command+P 可以快速跳转到当前项目中的任意文件，可进行关键词匹配。
* 用 Command+P 后 @ (或是Command+R)可以快速列出/跳转到某个函数（很爽的是在 markdown 当中是匹配到标题，而且还是带缩进的！）。
* 用 Command+P 后 # 可以在当前文件中进行搜索。
* 用 Command+P 后 : (或是Ctrl+G)加上数字可以跳转到相应的行。
* 而更酷的是你可以用 Command+P 加上一些关键词跳转到某个文件同时加上 @ 来列出/跳转到目标文件中的某个函数，或是同时加上 # 来在目标文件中进行搜索，或是同时加上 : 和数字来跳转到目标文件中相应的行。

<!-- more -->

|  Mac   | Windows |                         |               |
|--------|---------|-------------------------|---------------|
| Cmd+p  | Ctrl+p  | Goto Anything           |               |
| Cmd+r  | Ctrl+r  | 快速列出/跳转到某个函数 | 相当于Cmd+p+@ |
| Ctrl+g | Ctrl+g  | 跳转到相应的行          | 当于Cmd+p+:   |

## 行编辑：

|         Mac          |       Windows        |                          |
|----------------------|----------------------|--------------------------|
| Ctrl+Shit+Up/Down    | Ctrl+Alt+Up/Down     | 光标上下选择多行         |
| Ctrl+Shit+Left/Right | Ctrl+Shit+Left/Right | 光标左右选择多列文字     |
| Ctrl+Left/Right      | Ctrl+Left/Right      | 光标左右跳转             |
| Ctrl+j               | Ctrl+j               | 合并选择的多行文本到一行 |


## 多重选择：

|    Mac     | Windows |                        |
|------------|---------|------------------------|
| Cmd+d      | Ctrl+d  | 选中下一个同样文本内容 |
| Ctrl+Cmd+g | Alt+F3  | 选中所有同样文本内容   |


## 行操作：

|       Mac        |      Windows      |                         |
|------------------|-------------------|-------------------------|
| Cmd+Shit+d       | Ctrl+p            | 重复行                  |
| Cmd+x            | Ctrl+x            | 删除行                  |
| Ctrl+Cmd+Up/Down | Ctrl+Shit+Up/Down | 上下移动当前行/选中多行 |

## 多文件窗口
|    Mac    |  Windows   |                 |
|-----------|------------|-----------------|
| Cmd+alt+n | Ctrl+alt+n | 使用n个文件窗口 |

## 查找替换
|  Mac  | Windows |                       |
|-------|---------|-----------------------|
| Cmd+f | Ctrl+f  | Find...               |
|       | F3      | Find Next             |
|       | Ctrl+i  | Incremental Find      |
|       | Ctrl+e  | Use Selection to Find |
|       | 无      | Find In Files...      |
|       | Ctrl+h  | Replace               |

    
## 自定义快捷键
修改Key Bindings - User:

```json
[
    {"keys": ["ctrl+alt+f"], "command": "show_panel", "args": {"panel": "find_in_files"} },
    {"keys": ["ctrl+shift+f"], "command": "reindent"},
    {"keys": ["ctrl+shift+r"], "command": "reveal_in_side_bar"}
]
```

打开command日志可以查到操作的command命令和参数用于绑定快捷键

```python
sublime.log_commands(True)
```

# Snippet：
添加xxx.sublime-snippet文件到User/Packages目录

```xml
<snippet>
    <content><![CDATA[
---
title: "${1:title}"
description: ""
category: ${2:category}
tags: [${3:tags}]
---
]]></content>
    <!-- Optional: Set a tabTrigger to define how to trigger the snippet -->
    <tabTrigger>post</tabTrigger>
    <!-- Optional: Set a scope to limit where the snippet will trigger -->
    <scope>text.html.markdown</scope>
    <description>markdown blog post setting</description>
</snippet>
```



# Build System
添加xxx.sublime-build文件到User/Packages目录

```json
{
    "cmd": ["jython.bat", "-u", "$file"],
    "file_regex": "^[ ]*File \"(...*?)\", line ([0-9]*)",
    "selector": "source.python"
}
```

# 命令行工具：
Windows:
添加安装目录到PATH环境变量

Mac:

```
ln -s "/Applications/Sublime Text 3.app/Contents/SharedSupport/bin/subl" ~/bin/subl
```

# 插件：
安装[Package Control][3]用户管理插件

```
import urllib.request,os,hashlib; h = '2deb499853c4371624f5a07e27c334aa' + 'bf8c4e67d14fb0525ba4f89698a6d7e1'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
```

## 一些常用插件和配置

### Markdown Editing：
Markdown GFM Settings - User:

```json
{
    "extensions": [
        "md",
        "mdown",
        "markdown"
    ]
}
```

### Markdown Preview:
Settings - User:

```json
{
    "parser": "github"
}
```

Key Bindings - User:

```json
{ "keys": ["alt+m"], "command": "markdown_preview", "args": {"target": "browser", "parser":"default"} }
```

### Lint 扩展
SublimeLinter 试过多个同类扩展之后发现它最好用，并且支持多种语言、不需要热键——它在输入时就自动校验。

### 更多插件：
Side​Bar​Enhancements,Terminal,GitGutter,Table Editor,Emmet,AllAutocomplete,IMESuport

### 编写插件
宏无法达到要求时，定义一个扩展：
[How to Create a Sublime Text 2 Plugin][8] 
[Sublime Text plugin-examples][9]

# 宏编辑
需要批量热键操作的话，可以定义宏： 
[Macros — Sublime Text Unofficial Documentation][7]

# Project

 配置prj-name.sublime-project，主要是单独设定一致的缩进格式和文件排除（在 cmd + p, GOTO 命令时加快速度）选项：

```
{
    "folders":
    [
        {
            "path": "path_to_project",
            "folder_exclude_patterns": ["img","x-library"]
        }

    ],
    "settings":
    {
        "translate_tabs_to_spaces": true,
        "tab_size": 4
    }
}
```

# 配置移动化
最好全部定义在 `path_to_sublime/Packages/User/` 目录中，然后用一个 repo 保存它们，这样随时可以同步到你的所有设备上，并且不同的操纵系统有不同的文件来进行配置

也可以使用的方式是link到快盘同步目录自动同步

# 一些资源链接：

1. [Sublime Text 全程指南][5]
2. [Gif多图：我常用的 16 个 Sublime Text 快捷键][1] 
3. [10 Essential Sublime Text Plugins for Full-Stack Developers][2] 
4. [Sublime Text 2: Snippet scopes][4]
5. [知乎Sublime Text相关问答][6]
6. [设置 Sublime Text 的 Python 开发环境](http://www.oschina.net/translate/setting-up-sublime-text-for-python-development)


[1]:http://blog.jobbole.com/82527/
[2]:http://www.sitepoint.com/10-essential-sublime-text-plugins-full-stack-developer/
[3]:https://packagecontrol.io/
[4]:https://gist.github.com/iambibhas/4705378
[5]:http://zh.lucida.me/blog/sublime-text-complete-guide/
[6]:http://www.zhihu.com/topic/19668076
[7]:http://readthedocs.org/docs/sublime-text-unofficial-documentation/en/latest/extensibility/macros.html
[8]:http://net.tutsplus.com/tutorials/python-tutorials/how-to-create-a-sublime-text-2-plugin/
[9]:http://www.sublimetext.com/docs/plugin-examples
