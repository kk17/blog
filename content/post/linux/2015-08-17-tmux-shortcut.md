---
title: "Tmux快捷键"
description: ""
categories: ["note"]
tags: ["linux","tmux"]
date: 2015-08-17T09:00:00+08:00
slug: "tmux-shortcut"
aliases:
  - /note/tmux-shortcut
  - /note/tmux-shortcut.html
---

### 在tmux内：

|        功能        |             命令             |
|--------------------|------------------------------|
| 创建窗口           | C-b c                        |
| 关闭窗口           | C-b &                        |
| 重命名窗口         | C-b ,                        |
| 重命名会话         | C-b $                        |
| 切换到上一窗口     | C-b p                        |
| 切换到下一窗口     | C-b n                        |
| 列出窗口供选择     | C-b w                        |
| detach             | C-b d                        |
| 列出列出快捷键     | C-b ?                        |
| 创建右面板         | C-b %                        |
| 创建下面板         | C-b "                        |
| 选择面板           | C-b o                        |
| 列出会话供选择        | C-b s                        |
| 方向键选面板       | C-b 箭头                     |
| 关闭面板           | C-b x                        |
| 切换布局           | C-b space                    |
| 切换布局           | C-b Esc 1-5                  |
| 选择窗口           | C-b Num                      |
| 输入命令           | C-b :                        |
| 多面板同步发送命令 | C-b : setw synchronize-panes |

<!-- more -->

### 在tmux外：

|        功能        |                          命令                         |
|--------------------|-------------------------------------------------------|
| 创建会话           | tmux new-session -s work -n tomcat                    |
| 创建会话(不attach) | tmux new-session -s work -n tomcat -d                 |
| 创建会话(输入命令) | tmux new-session -t work -n tomcat -d “ssh user@host” |
| attach会话         | tmux a -t work                                   |
| 列出会话           | tmux ls                                               |
| 关闭会话           | tmux kill-session -t work                             |
| 发送命令           | tmux send-keys -t work:editor "emacs" C-m             |

### 更多快捷键：

|         key         |             action            |
|---------------------|-------------------------------|
| bind-key        C-o | rotate-window                 |
| bind-key        C-z | suspend-client                |
| bind-key      Space | next-layout                   |
| bind-key          ! | break-pane                    |
| bind-key          " | split-window                  |
| bind-key          # | list-buffers                  |
| bind-key          $ | rename-session                |
| bind-key          % | split-window                  |
| bind-key          & | kill-window                   |
| bind-key          ' | select-window                 |
| bind-key          ( | switch-client -p              |
| bind-key          ) | switch-client -n              |
| bind-key          , | rename-window                 |
| bind-key          - | delete-buffer                 |
| bind-key          . | cmove-window                  |
| bind-key          0 | select-window -t :0           |
| bind-key          1 | select-window -t :1           |
| bind-key          2 | select-window -t :2           |
| bind-key          3 | select-window -t :3           |
| bind-key          4 | select-window -t :4           |
| bind-key          5 | select-window -t :5           |
| bind-key          6 | select-window -t :6           |
| bind-key          7 | select-window -t :7           |
| bind-key          8 | select-window -t :8           |
| bind-key          9 | select-window -t :9           |
| bind-key          : | command-prompt                |
| bind-key          ; | last-pane                     |
| bind-key          = | choose-buffer                 |
| bind-key          ? | list-keys                     |
| bind-key          D | choose-client                 |
| bind-key          L | switch-client -l              |
| bind-key          [ | copy-mode                     |
| bind-key          ] | paste-buffer                  |
| bind-key          c | new-window                    |
| bind-key          d | detach-client                 |
| bind-key          f | find-window                   |
| bind-key          i | display-message               |
| bind-key          l | last-window                   |
| bind-key          n | next-window                   |
| bind-key          o | select-pane -t :.+            |
| bind-key          p | previous-window               |
| bind-key          q | display-panes                 |
| bind-key          r | refresh-client                |
| bind-key          s | choose-session                |
| bind-key          t | clock-mode                    |
| bind-key          w | choose-window                 |
| bind-key          x | kill-pane                     |
| bind-key          { | swap-pane -U                  |
| bind-key          } | swap-pane -D                  |
| bind-key          ~ | show-messages                 |
| bind-key      PPage | copy-mode -u                  |
| bind-key -r      Up | select-pane -U                |
| bind-key -r    Down | select-pane -D                |
| bind-key -r    Left | select-pane -L                |
| bind-key -r   Right | select-pane -R                |
| bind-key        M-1 | select-layout even-horizontal |

### 一些链接：

- [tmux入门指南 | Abyssly's Blog](http://abyssly.com/2013/11/04/tmux_intro/)
- [使用tmux [FreeBSDChina Wiki]](https://wiki.freebsdchina.org/software/t/tmux)
- [keyboard shortcuts - How to quickly switch to n.10+ windows in tmux - Super User](http://superuser.com/questions/755634/how-to-quickly-switch-to-n-10-windows-in-tmux)
