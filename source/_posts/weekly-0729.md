---
title: weekly 0729
date: 2016-10-09 23:00:44
categories: WeeklyTask
tags: 每周总结
---
1、本地 git 切换到远程分支

首先，通过 git branch -va 查看本地 ＋ 远程的分支列表,比如：

```shell
* master              0840594 merge master and 1.0.0
remotes/origin/1.0.0  743012a 'update'
remotes/origin/2.0.0  2787838 udpate
remotes/origin/HEAD   -> origin/master
remotes/origin/master 0840594 merge master and 1.0.0
```
<!-- more -->

如果想切换到 origin/2.0.0 的分支，我们可以
```shell
git branch remotes/origin/2.0.0
```

不过结果并不如意：
```shell
* (detached from origin/2.0.0)
master
```

git branch 会看到上面的信息，这里还需要一步操作：

```shell
git checkout -b 2.0.0
```

-b 的意思是 base，以当前分支为 base，新建一个名叫 2.0.0 的分支，这里当然也可以使用其他的命名。此时再执行 git branch 就能看到：

```shell
$ git br
  master
* 2.0.0
```

最直接的方法是：

```shell
git checkout -t origin/2.0.0
```
能够直接新建本地分支，将远程分支提取出来。
