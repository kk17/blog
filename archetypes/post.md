---
{{ $noDateName := replaceRE "^\\d{2,4}\\-\\d{1,2}\\-\\d{1,2}\\-" "" .TranslationBaseName }}title: "{{ replace $noDateName "-" " " | title }}"
slug: "{{ $noDateName }}"
date: {{ .Date }}
lastmod: {{ .Date }}
draft: true
keywords: []
description: ""
tags: []
categories: [{{ $parentDirs := split (path.Dir .File.Path) "/" }}{{ $parentDirsLen := len $parentDirs }}{{ if gt $parentDirsLen 1 }}"{{ index $parentDirs 1 }}"{{ end }}]
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

<!--more-->
