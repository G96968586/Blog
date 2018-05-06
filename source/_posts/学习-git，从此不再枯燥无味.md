---
title: 学习 git，从此不再枯燥无味
date:  2016-02-02 10:56:36
categories: Git
tags: git
---
最近在玩一个叫 “githug” 的游戏，看到这个名字，也许你马上就联想到了 git。是的，这是一个跟 git 相关的游戏，它把平常可能遇到的一些场景都实例化，变成一个一个的关卡，通过通关的形式，让你快速的学习 Git 并发挥其最大的威力。
<!-- more -->

Github 地址在这里：[《GitHug》](https://github.com/Gazler/githug)。


下面介绍下怎么安装这个游戏。

### 安装

因为 githug 是用 Ruby 编写的，所以我们可以通过 gem 来安装，安装命令如下：

```
$ gem install githug

```

如果安装失败，就试试下面的命令，一般都是权限引起的，

```
$ sudo gem install githug

```

安装成功后，随便进入一个目录，也可新建一个目录，然后敲入

```
$ githug

```

会提示你 githug 目录找不到，是否创建一个，

```
********************************************************************************
*                                    Githug                                    *
********************************************************************************
No githug directory found, do you wish to create one? [yn]  

```

输入 y，会新建一个 githug 文件夹，cd githug 进去，就可以开始游戏了。

### 基本操作

这里我们首先熟悉下几个基本操作：

* play 检查是否过关，每一关完成后用 githug play 检查一下，就可以知道有没有答对
* hint 这是我最常用的一个操作，会显示本关卡的过关提示
* reset 重置关卡，有时候答错了，环境已经变了，此时万一你输入了正确的答案，结果还是错的，因为你前面的环境已经被“污染”了，所以每当答错题目，记得 githug reset 一遍
* levels 显示关卡列表，目前一共有 54 关

### 示例

因为我目前处于 44 关卡，我就拿这个关卡做为一个示例吧，首先重置下，

```
$ githug reset 

```

```

  git_hug git:(master) githug reset
********************************************************************************
*                                    Githug                                    *
********************************************************************************
resetting level

Name: rename_commit
Level: 44
Difficulty: ***

Correct the typo in the message of your first (non-root) commit.

```

从输出的内容上可以看到有题目的名字，关卡数和难度。难度下面是本题目的通关内容。好，我们现在来做题。

rename_commit,顾名思义，就是重命名 commit 的内容，“Correct the typo in the message of your first (non-root) commit”，"typo" 是什么鬼？查了一下，原来是“错别字”的意思，好了，现在明白题目的意思了，就是让我们找到 "first commit" 的那条commit 然后纠正我们的错误信息。

```
$ git log

```
```
0e5689e (HEAD -> master) Second commit
bf48411 First coommit
008128a Initial commit
(END) 

```

OK,这是一道很好的题目，之前我也遇到了这种情况，比如还没写完 commit 的 message ，然后一不小心就按下了回车，结果就把 commit 提交上去了，这时候却不知道怎么修改，之前的我是选择忽略的。。。，现在既然又遇到了，那就把它弄个明白吧，可是怎么做好呢？我们来看下提示。

```
$ githug hint

```
```
********************************************************************************
*                                    Githug                                    *
********************************************************************************
Take a look the `-i` flag of the rebase command.
```

"Take a look the `-i` flag of the rebase command.", 输入 

```
$ git rebase --help

```

会看到很详细的说明文档，我们找到带 －i 那条说明，


-i, --interactive
           Make a list of the commits which are about to be rebased. Let the user edit
           that list before rebasing. This mode can also be used to split commits (see
           SPLITTING COMMITS below).
           


ok,找到 First coommit 的 commit id,敲入

```
$ git rebase -i bf48411

```

```
pick 0e5689e Second commit

# Rebase bf48411..0e5689e onto bf48411 (1 command(s))
#
# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# f, fixup = like "squash", but discard this commit's log message
# x, exec = run command (the rest of the line) using shell
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
~                                             

```

好像看不到有 "First coommit" 的信息啊？咋回事？后面发现，原来 -i 指向的是我们要修改的前一条 commit，重来，输入 Initial commit 的 id，

```
$ git rebase -i 008128a

```

```
pick bf48411 First coommit
pick 0e5689e Second commit

# Rebase 008128a..0e5689e onto 008128a (2 command(s))
#
# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# f, fixup = like "squash", but discard this commit's log message
# x, exec = run command (the rest of the line) using shell
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out

```

终于看到了熟悉的字眼了，把 First coommit 那条的 pick 改成 edit，然后保存。

```
pick bf48411 First coommit --> edit bf48411 First coommit

```

```
  git_hug git:(master) git rebase -i 008128a
Stopped at bf48411792b6e9e2e36407983e40e0610a3febf2... First coommit
You can amend the commit now, with

	git commit --amend 

Once you are satisfied with your changes, run

	git rebase --continue


```

此时要 git commit --amend 了，

```
  git_hug git:(bf48411) git commit --amend -m "First commit"
[detached HEAD 63e13d1] First commit
 Date: Tue Feb 2 10:35:06 2016 +0800
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 file1

```
最后还要 git rebase --continue,因为


--continue
           Restart the rebasing process after having resolved a merge conflict.


```
  git_hug git:(63e13d1) git rebase --continue 
Successfully rebased and updated refs/heads/master.
```

Ok,验证一下，

```
  git_hug git:(master) githug play
********************************************************************************
*                                    Githug                                    *
********************************************************************************
Congratulations, you have solved the level!

Name: squash
Level: 45
Difficulty: ****

You have committed several times but would like all those changes to be one commit.
```

通关咯！！！下面紧接的是 45关，这里我就不再示例了，伙伴们，赶紧搞起来吧！学习 git，从此不再枯燥无味。
