---
title: 'weekly-1125 '
date: 2016-11-27 23:46:11
categories: WeeklyTask
tags: 每周总结
---
* Android Logcat的Material颜色主题

要改变 Android Studio 的 Logcat 你需要这样做：进入 Preferences ( Windows 上是 Settings / Linux machines ) → Editor → Colors & Fonts → Android Logcat，然后为每种类型的log设置前景颜色(foreground)。

![img](http://p3.pstatp.com/large/10f3000b2045b867f40e)

<!-- more -->

我使用的material颜色：

Assert #BA68C8

Debug #2196F3

Error #F44336

Info #4CAF50

Verbose #BBBBBB

Warning #FF9800

注意里面有几个现有的主题，可以直接修改现有主题(不建议)，或者点击save as按钮拷贝一个主题并改名为Material theme Color然后再改变每种类型log的颜色。

* 防止当前应用崩溃时 Logcat 清除 log

在 Android Monitor 面板的右上方点击下拉菜单中的 choose Edit filter configuration：

![img](http://p1.pstatp.com/large/11af000b840a002fe833)

* 无干扰模式

你可以到 View → Enter Distraction Free Mode 里启用它

![img](http://p1.pstatp.com/large/10f3000b2046565442d3)

在无干扰模式下，编辑器占据了整个IntelliJ IDEA窗口，没有任何tab或者工具按钮。代码居中显示。[ IntelliJ Idea Viewing Modes ]

![img](http://p3.pstatp.com/large/10e6000fb226567e1a0f)

* 使用 Live Templates

你可以使用快捷键：cmd + j (Windows / Linux: ctrl + j)。

![img](http://p3.pstatp.com/large/11b100005c12e0ddbb70)

可以使用已经定义好了的 Live Templates，比如 Toasts 或者 if 语句。

可以使用自定义的 templates。这里是 Reto Meier 的一篇不错的参考文章。你也可以参考 IntelliJ IDEA 的文档。

* option + enter

把一个硬编码的字符串放到资源文件中：option + enter (Windows / Linux: alt + enter)。光标必须在这个文字之上时才能使用这个快捷键。看下面的gif图：

![img](http://p3.pstatp.com/large/10f3000b2047df7703c4)

* 查看远程分支

git branch -a

* 查看本地分支

git branch

* CSS实现单行、多行文本溢出显示省略号（…）

如果实现单行文本的溢出显示省略号同学们应该都知道用 text-overflow:ellipsis 属性来，当然还需要加宽度 width 属来兼容部分浏览。

实现方法：

```javascript
overflow: hidden;
text-overflow:ellipsis;
white-space: nowrap;
```

效果图：
![](http://www.daqianduan.com/wp-content/uploads/2015/10/dome1.png)

但是这个属性只支持单行文本的溢出显示省略号，如果我们要实现多行文本溢出显示省略号呢。

接下来重点说一说多行文本溢出显示省略号，如下。

实现方法：

```javascript
display: -webkit-box;
-webkit-box-orient: vertical;
-webkit-line-clamp: 3;
overflow: hidden;

```

效果图：
![](http://www.daqianduan.com/wp-content/uploads/2015/10/dome2.png)

适用范围：
因使用了WebKit的CSS扩展属性，该方法适用于WebKit浏览器及移动端；

注：

-webkit-line-clamp;
用来限制在一个块元素显示的文本的行数。 为了实现该效果，它需要组合其他的WebKit属性。

常见结合属性：

display: -webkit-box; 必须结合的属性 ，将对象作为弹性伸缩盒子模型显示 。

-webkit-box-orient; 必须结合的属性 ，设置或检索伸缩盒对象的子元素的排列方式 。

* input 输入框点击时去掉外边框方法

```javascript
input {
  outline: white ;/* 颜色随便设置 */
  border: none;
}
```
