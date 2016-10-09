---
title: weekly 0708
date: 2016-10-09 23:06:29
categories: WeeklyTask
tags: 每周总结
---
* [在WebView自身打开链接 -- 关于WebViewClient类shouldOverrideUrlLoading的错误用法](http://www.codes51.com/article/detail_101733.html)

* Android 24之后(即 Android N)，可以很方便的查看自己 app 是否打开了消息通知开关

详情：
 Now you can check it, as said in [this Google I/O 2016 video](https://www.youtube.com/watch?v=w45y_w4skKs&feature=youtu.be&list=PLOU2XLYxmsILe6_eGvDN3GyiodoV3qNSC&t=192)

怎么使用呢？看下我的代码：
```Java
boolean isOpen = NotificationManagerCompat.from(this).areNotificationsEnabled();
```
这里需要注意的是，在 API 19 以下方法 areNotificationsEnabled 默认都返回 true，在 API 19+ (包括19)是有效果的。
