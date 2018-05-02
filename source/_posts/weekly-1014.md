---
title: weekly 1014
date: 2016-10-13 23:34:46
categories: WeeklyTask
tags: 每周总结
---
* 在 Andorid Studio 中查看 Gradle 添加的依赖时，只有平行的一级，看不出任何从属关系，

![img](http://alphayang.github.io/img/graldle_flat_dep_tree.png)

特别是出现依赖冲突的时候，在build.gradle 中根据没有添加的包，此时可以在项目根目录下的 build.gradle 中添加如下代码：
<!-- more -->

```groovy
subprojects {
    task allDeps(type: DependencyReportTask) {}
}
```

然后在 Terminal 下运行：

```shell
./gradlew allDeps
```

就可以看到依赖树啦!

```groovy
compile - Classpath for compiling the main sources.
...
+--- com.android.support:design:24.0.+ -> 24.0.0
|    +--- com.android.support:support-v4:24.0.0
|    |    \--- com.android.support:support-annotations:24.0.0
|    +--- com.android.support:recyclerview-v7:24.0.0
|    |    +--- com.android.support:support-annotations:24.0.0
|    |    \--- com.android.support:support-v4:24.0.0 (*)
|    \--- com.android.support:appcompat-v7:24.0.0
|         +--- com.android.support:support-v4:24.0.0 (*)
|         +--- com.android.support:support-vector-drawable:24.0.0
|         |    \--- com.android.support:support-v4:24.0.0 (*)
|         \--- com.android.support:animated-vector-drawable:24.0.0
|              \--- com.android.support:support-vector-drawable:24.0.0 (*)
+--- com.android.support:appcompat-v7:24.0.+ -> 24.0.0 (*)
+--- com.android.support:recyclerview-v7:24.0.+ -> 24.0.0 (*)
+--- com.android.support:support-v4:24.0.+ -> 24.0.0 (*)
+--- com.alibaba:fastjson:1.2.7
+--- com.android.support:multidex:1.0.0
+--- com.nineoldandroids:library:2.4.0
+--- com.wang.avi:library:1.0.1
|    +--- com.android.support:appcompat-v7:22.2.0 -> 24.0.0 (*)
|    \--- com.nineoldandroids:library:2.4.0
+--- me.drakeet.materialdialog:library:1.2.8
+--- com.balysv:material-ripple:1.0.2
+--- com.zhy:okhttputils:2.2.0
|    \--- com.squareup.okhttp3:okhttp:3.0.1
|         \--- com.squareup.okio:okio:1.6.0
+--- com.czt.mp3recorder:library:1.0.2
|    \--- com.android.support:support-v4:23.1.1 -> 24.0.0 (*)
...
```

* 客户端本地使用 Android Studio 调试时出现 **Failure [INSTALL_CANCELED_BY_USER]** 的问题

今天在我使用小米 Note 本地调试 app 时，每次在 Install app 环节就出现了 **Failure [INSTALL_CANCELED_BY_USER]** 的错误，字面意义很容易理解，被用户手动取消安装了，呵，说着倒是挺轻松的，可我压根就没有取消，查看手机开发者调试开关和 USB 开关都打开了，网上查了一下，大概有下面几种解决方法：

1.确保手机处于开发者模式

2.在手机上，勾选 系统设置 -> 安全 -> 未知来源

3.安装的时候手机是否处于锁屏状态，若是，取消锁屏

4.有的手机需要手动安装，比如小米3

5.手机内存空间可能不足

上面五种方法对我来说都没有用，正当我在烦恼的时候，我突然想起是不是我更新了 MIUI 系统的原因造成的，因为之前我是可以调试的。打开手机开发者选项，看到多出了很多的开关选项，其中有一个“允许通过USB安装应用”的开关，打开它，发现还需要小米账号登录，真烦，无奈，我还是登录了，然后把这个开关打开，重新通过 Android Studio 把 app 跑起来，结果可以了！

如果你在小米的手机上也遇到这个问题，不妨试试我的方法。

**注：更新后的小米系统版本如下**：

```
Android 版本: 6.0.1 MMB29M

MIUI 版本: MIUI 8.6.9.29|开发版 (靠，还是开发版)
```

* Chrome 上模拟 UA

打开开发者模式，More tools -> Network conditions

![](https://gw.alicdn.com/tps/TB1rfAfNFXXXXXrapXXXXXXXXXX-782-580.png)

进入下面的页面，

![](https://gw.alicdn.com/tps/TB1PQ.qNFXXXXbJXVXXXXXXXXXX-1156-618.png)

去掉 Select automatically 选项，然后选择平台，下面的 UA 就可以根据你的需求更改了。
