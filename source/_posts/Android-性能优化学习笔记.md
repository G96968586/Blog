---
title: Android 性能优化学习笔记
date: 2016-07-17 23:04:06
categories: Android 
tags: Android 
---

* 渲染
* 电量
* 内存
* 运算

### UI 渲染

Android 每隔 16 ms 就会发出触发 UI 渲染的 VSYNC 信号，如果每次的渲染都成功，就能保证页面达到流畅，此时所需要的画面帧数是每秒达到 60 帧，为了能够实现 60 fps，意味着程序的大多数操作都必须在16ms内完成。

![](http://hukai.me/images/draw_per_16ms.png)

下面是一个丢帧的例子：

![](http://hukai.me/images/vsync_over_draw.png)

丢帧的原因有：layout 太过复杂、UI 上有层叠太多的绘制单元、动画执行次数过多等等，这些都会导致CPU 或者 GPU 负载过重。

工具协助：

* HierarchyViewer -> Activity 布局是否过于复杂
* 使用手机设置里面的开发者选项，打开 Show GPU Overdraw 等选项进行观察
* TraceView -> CPU 的执行情况

#### 过度绘制(Overdraw)

指屏幕上的某个像素在同一帧的时间内被绘制了多次。

![](http://hukai.me/images/overdraw_hidden_view.png)

通过手机设置里面的开发者选项，打开 Show GPU Overdraw 的选项，可以观察 UI 上的 Overdraw 情况.

![](http://hukai.me/images/overdraw_options_view.png)

目标就是尽量减少红色 Overdraw，看到更多的蓝色区域。

#### 理解 VSYNC

- Refresh Rate：代表了屏幕在一秒内刷新屏幕的次数，这取决于硬件的固定参数，例如60Hz。
- Frame Rate：代表了GPU在一秒内绘制操作的帧数，例如30fps，60fps。

GPU 负责获取图形数据进行渲染，硬件负责把渲染后的内容呈现到屏幕上，两者不停相互协作。

![](http://hukai.me/images/vsync_gpu_hardware.png)

如果发生帧率与刷新频率不一致的情况，就会容易出现 **Tearing** 的现象，(画面上下两部分显示内容发生断裂，来自不同的两帧数据发生重叠)。

![](http://hukai.me/images/vsync_gpu_hardware_not_sync.png)

![](http://hukai.me/images/vsync_buffer.png)

我们遇到更多的情况是帧率小于刷新频率,

![](http://hukai.me/images/vsync_gpu_hardware_not_sync2.png)

在这种情况下，某些帧显示的画面内容就会与上一帧的画面相同。糟糕的事情是，帧率从超过 60fps 突然掉到 60fps 以下，这样就会发生 **LAG**，**JANK**，**HITCHING** 等卡顿掉帧的不顺滑的情况。这也是用户感受不好的原因所在。

#### Profile GPU Rendering

![](http://hukai.me/images/tools_gpu_profile_rendering.png)

可以在手机画面上看到丰富的 GPU 绘制图形信息，分别关于 StatusBar，NavBar，激活的程序 Activity区域的 GPU Rending 信息。

随着界面的刷新，界面上会滚动显示垂直的柱状图来表示每帧画面所需要渲染的时间，柱状图越高表示花费的渲染时间越长。

![](http://hukai.me/images/tools_gpu_profile_rendering_graphic_activity.png)

![](http://hukai.me/images/tools_gpu_rendering_bar.png)

中间有一根绿色的横线，代表 16ms，我们需要确保每一帧花费的总时间都低于这条横线，这样才能够避免出现卡顿的问题。

![](http://hukai.me/images/tools_gpu_profile_three_color.png)

每一条柱状线包括三部分：

* 蓝色，代表测量绘制 Display List 的时间
* 红色，代表 OpenGL 渲染 Display List 所需要的时间
* 黄色，则代表了 CPU 等待 GPU 处理的时间

#### 为什么是 60 fps

我们通常都会提到 60fps 与 16ms，可是知道为何会是以程序是否达到 60fps 来作为 App 性能的衡量标准吗？这是因为人眼与大脑之间的协作无法感知超过 60fps 的画面更新。

12fps 大概类似手动快速翻动书籍的帧率，这明显是可以感知到不够顺滑的。24fps 使得人眼感知的是连续线性的运动，这其实是归功于运动模糊的效果。24fps 是电影胶圈通常使用的帧率，因为这个帧率已经足够支撑大部分电影画面需要表达的内容，同时能够最大的减少费用支出。但是低于 30fps 是无法顺畅表现绚丽的画面内容的，此时就需要用到 60fps 来达到想要的效果，当然超过 60fps 是没有必要的。

开发app的性能目标就是保持 60fps，这意味着每一帧你只有 16ms=1000/60 的时间来处理所有的任务。

#### **Resterization栅格化**

![](http://hukai.me/images/gpu_rasterization.png)

是负责绘制 Button，Shape，Path，String，Bitmap 等组件最基础的操作。它把那些组件拆分到不同的像素上进行显示。这是一个很费时的操作，GPU 的引入就是为了加快栅格化的操作。

![](http://hukai.me/images/gpu_cpu_rasterization.png)

CPU (计算 UI 组件) -> [Polygons，Texture纹理] -> GPU (Resterization) -> 栅格化渲染 -> 屏幕

然而每次从 CPU 转移到 GPU 是一件很麻烦的事情，所幸的是 OpenGL ES 可以把那些需要渲染的纹理Hold 在 GPU Memory 里面，在下次需要渲染的时候直接进行操作。所以如果你更新了 GPU 所 hold 住的纹理内容，那么之前保存的状态就丢失了。

通常来说，Android 需要把 XML 布局文件转换成 GPU 能够识别并绘制的对象。这个操作是在 **DisplayList**的帮助下完成的。DisplayList 持有所有将要交给 GPU 绘制到屏幕上的数据信息。

需要注意的是：任何时候View中的绘制内容发生变化时，都会重新执行创建 DisplayList，渲染DisplayList，更新到屏幕上等一系列操作。这个流程的表现性能取决于你的 View 的复杂程度，View 的状态变化以及渲染管道的执行性能。举个例子，假设某个 Button 的大小需要增大到目前的两倍，在增大Button 大小之前，需要通过父 View 重新计算并摆放其他子 View 的位置。修改 View 的大小会触发整个HierarcyView 的重新计算大小的操作。如果是修改 View 的位置则会触发 HierarchView 重新计算其他View 的位置。如果布局很复杂，这就会很容易导致严重的性能问题。我们需要尽量减少 Overdraw。

![](http://hukai.me/images/layout_three_steps.png)

#### Apply clipRect and quickReject - Quiz & Solution

![](http://hukai.me/images/android_perf_course_clip_1.png)

上面的示例图中显示了一个自定义的 View，主要效果是呈现多张重叠的卡片。这个 View 的 onDraw 方法如下图所示：

![](http://hukai.me/images/android_perf_course_clip_3.png)

![](http://hukai.me/images/android_perf_course_clip_2.png)

是什么原因导致过度绘制的呢？

下面的代码显示了如何通过 clipRect 来解决自定义 View 的过度绘制，提高自定义 View 的绘制性能：

![](http://hukai.me/images/android_perf_course_clip_code_compare.png)

优化之后的效果图：

![](http://hukai.me/images/android_perf_course_clip_result.png)

### Nested Hierarchies and Performance

提升布局性能的关键点是尽量保持布局层级的扁平化，避免出现重复的嵌套布局。例如下面的例子，有2行显示相同内容的视图，分别用两种不同的写法来实现，他们有着不同的层级。

![](http://hukai.me/images/android_perf_course_hierarchy_1.png)

![](http://hukai.me/images/android_perf_course_hierarchy_2.png)

下图显示了使用2种不同的写法，在 Hierarchy Viewer 上呈现出来的性能测试差异：

![](http://hukai.me/images/android_perf_course_hierarchy_3.png)

下图举例演示了如何优化 ListItem 的布局，通过 RelativeLayout 替代旧方案中的嵌套 LinearLayout 来优化布局:

![](http://hukai.me/images/android_perf_course_hierarchy_4.png)

#### GC 

**Generational Heap Memory**

![](http://hukai.me/images/memory_mode_generation.png)

![](http://hukai.me/images/android_memory_gc_mode.png)

![](http://hukai.me/images/gc_threshold.png)

![](http://hukai.me/images/gc_event_thread_stop.png)

通常来说，单个的 GC 并不会占用太多时间，但是大量不停的 GC 操作则会显著占用帧间隔时间 (16ms)。如果在帧间隔时间里面做了过多的 GC 操作，那么自然其他类似计算，渲染等操作的可用时间就变得少了。

导致 GC 频繁执行的原因有两个：

- **Memory Churn 内存抖动**，内存抖动是因为大量的对象被创建又在短时间内马上被释放。
- 瞬间产生大量的对象会严重占用 Young Generation 的内存区域，当达到阀值，剩余空间不够的时候，也会触发 GC。即使每次分配的对象占用了很少的内存，但是他们叠加在一起会增加 Heap 的压力，从而触发更多其他类型的 GC。这个操作有可能会影响到帧率，并使得用户感知到性能问题。

![](http://hukai.me/images/gc_overtime.png)

解决上面的问题有简洁直观方法，如果你在 **Memory Monitor** (Memory Monitor 在 Android Studio 上的使用：https://developer.android.com/studio/profile/am-memory.html)里面查看到短时间发生了多次内存的涨跌，这意味着很有可能发生了内存抖动。

![](http://hukai.me/images/memory_monitor_gc.png)

同时我们还可以通过 **Allocation Tracker** 来查看在短时间内，同一个栈中不断进出的相同对象。这是内存抖动的典型信号之一。

#### 内存泄漏

![](http://hukai.me/images/memory_leak_profile_method.png)

寻找内存泄漏并修复这个漏洞是件很棘手的事情，你需要对执行的代码很熟悉，清楚的知道在特定环境下是如何运行的，然后仔细排查。

例如，你想知道程序中的某个 activity 退出的时候，它之前所占用的内存是否有完整的释放干净了？首先你需要在 activity 处于前台的时候使用 Heap Tool 获取一份当前状态的内存快照，然后你需要创建一个几乎不这么占用内存的空白 activity 用来给前一个 Activity 进行跳转，其次在跳转到这个空白的 activity 的时候主动调用 System.gc() 方法来确保触发一个 GC 操作。最后，如果前面这个 activity 的内存都有全部正确释放，那么在空白 activity 被启动之后的内存快照中应该不会有前面那个 activity 中的任何对象了。

![](http://hukai.me/images/memory_leak_track_method.png)



如果你发现在空白 activity 的内存快照中有一些可疑的没有被释放的对象存在，那么接下去就应该使用 **Alocation Track Tool** 来仔细查找具体的可疑对象。我们可以从空白 activity 开始监听，启动到观察activity，然后再回到空白 activity 结束监听。这样操作以后，我们可以仔细观察那些对象，找出内存泄漏的真凶。

#### Memory Performance

为了寻找内存的性能问题，Android Studio提供了工具来帮助开发者：

- **Memory Monitor：**查看整个 app 所占用的内存，以及发生 GC 的时刻，短时间内发生大量的 GC 操作是一个危险的信号。

![](http://hukai.me/images/memory_monitor_overview.png)

![](http://hukai.me/images/memory_monitor_free_allocation.png)

![](http://hukai.me/images/memory_monitor_gc_event.png)

- **Allocation Tracker：**使用此工具来追踪内存的分配，前面有提到过。
- **Heap Tool：**查看当前内存快照，便于对比分析哪些对象有可能是泄漏了的，请参考前面的Case。

#### Battery Performance

Purdue University 研究了最受欢迎的一些应用的电量消耗，平均只有 30% 左右的电量是被程序最核心的方法例如绘制图片，摆放布局等等所使用掉的，剩下的 70% 左右的电量是被上报数据，检查位置信息，定时检索后台广告信息所使用掉的。

有下面一些措施能够显著减少电量的消耗：

- 我们应该尽量减少唤醒屏幕的次数与持续的时间，使用 WakeLock 来处理唤醒的问题，能够正确执行唤醒操作并根据设定及时关闭操作进入睡眠状态。
- 某些非必须马上执行的操作，例如上传歌曲，图片处理等，可以等到设备处于充电状态或者电量充足的时候才进行。
- 触发网络请求的操作，每次都会保持无线信号持续一段时间，我们可以把零散的网络请求打包进行一次操作，避免过多的无线信号引起的电量消耗。关于网络请求引起无线信号的电量消耗，还可以参考这里 [优化下载以高效地访问网络](http://hukai.me/android-training-course-in-chinese/connectivity/efficient-downloads/efficient-network-access.html)
- 可以使用JobScheduler API来对一些任务进行定时处理，例如我们可以把那些任务重的操作等到手机处于充电状态，或者是连接到WiFi的时候来处理。 关于JobScheduler的更多知识可以参考 [管理设备的唤醒状态](http://hukai.me/android-training-course-in-chinese/background-jobs/scheduling/index.html)

从 Android 5.0 开始发布了 [Battery History Tool](https://github.com/google/battery-historian)，它可以查看程序被唤醒的频率，由谁唤醒的，持续了多长的时间，这些信息都可以获取到。

### 运算

Android 中的 Java 代码会经过编译优化再执行，代码的不同写法会影响到 Java 编译器的优化效率。

通常来说有两类运行效率差的情况：**第1种**是相对执行时间长的方法，我们可以很轻松的找到这些方法并做一定的优化。**第2种**是执行时间短，但是执行频次很高的方法，因为执行次数多，累积效应下就会对性能产生很大的影响。

### Traceview Walkthrough

通过 Android Studio 打开里面的 Android Device Monitor，切换到 DDMS 窗口，点击左边栏上面想要跟踪的进程，再点击上面的 Start Method Tracing 的按钮，如下图所示：

![](http://hukai.me/images/android_perf_compute_traceview.png)

启动跟踪之后，再操控 app，做一些你想要跟踪的事件，例如滑动 listview，点击某些视图进入另外一个页面等等。操作完之后，回到 Android Device Monitor，再次点击 Method Tracing 的按钮停止跟踪。此时工具会为刚才的操作生成 TraceView 的详细视图。

![](http://hukai.me/images/android_perf_compute_traceview_2.png)

### Batching and Caching

提升运算性能的两个技术：

**Batching** 是在真正执行运算操作之前对数据进行批量预处理，例如你需要有这样一个方法，它的作用是查找某个值是否存在与于一堆数据中。假设一个前提，我们会先对数据做排序，然后使用二分查找法来判断值是否存在。我们先看第一种情况，下图中存在着多次重复的排序操作。

![](http://hukai.me/images/android_perf_compute_batching_1.png)

在上面的那种写法下，如果数据的量级并不大的话，应该还可以接受，可是如果数据集非常大，就会有严重的效率问题。那么我们看下改进的写法，把排序的操作打包绑定只执行一次：

![](http://hukai.me/images/android_perf_compute_batching_2.png)

**Caching** 的理念很容易理解，在很多方面都有体现，下面举一个for循环的例子：

![img](http://hukai.me/images/android_perf_compute_caching.png)

上面这2种基础技巧非常实用，积极恰当的使用能够显著提升运算性能。

### Blocking the UI Thread

把那些可能有性能问题的代码移到非UI线程进行操作。

### Container Performance

避免我们重复造轮子，Java提供了很多现成的容器，例如 Vector，ArrayList，LinkedList，HashMap 等等，在 Android 里面还有新增加的 SparseArray 等，我们需要了解这些基础容器的性能差异以及适用场景。这样才能够选择合适的容器，达到最佳的性能。

> 代码性能优化小技巧

让下面的小技巧作为平时写代码的习惯，这样能够提升代码的效率。

高效的代码需要满足下面两个原则：

- 不要做冗余的工作
- 尽量避免执行过多的内存分配操作

#### http://hukai.me/android-training-performance-tips/



#### 内存

关于Allocation Tracker工具的使用，不展开了，参考下面的链接：

- [http://developer.android.com/tools/debugging/ddms.html#alloc](http://developer.android.com/tools/debugging/ddms.html#alloc)
- [http://android-developers.blogspot.com/2009/02/track-memory-allocations.html](http://android-developers.blogspot.com/2009/02/track-memory-allocations.html)

#### Android 管理应用的内存

##### 内存共享

* 系统启动 －》 zygote 进程载入通用 framework 代码和资源 －》(fork) app 进程 －》 加载 app 代码(共享 RAM 的资源)
* 大多数 static 的数据被 mmapped 到一个进程中。这不仅仅使得同样的数据能够在进程间进行共享，而且使得它能够在需要的时候被 paged out。
* 在很多情况下，Android 通过显式的分配共享内存区域(例如 ashmem 或者 grallo c)来实现一些动态RAM 区域能够在不同进程间进行共享

##### 分配与内存回收

* 每一个进程的 Dalvik heap 都有一个受限的虚拟内存范围(系统会给它一个上限)，即 heap size，它可以随着需要进行增长，但不会超过上限。
* 逻辑上讲的 heap size 和实际物理上使用的内存数量是不等的，Android 会计算一个叫做Proportional Set Size(PSS) 的值，它记录了那些和其他进程进行共享的内存大小。（假设共享内存大小是10M，一共有20个 Process 在共享使用，根据权重，可能认为其中有 0.3M 才能真正算是你的进程所使用的）
* Dalvik heap 与逻辑上的 heap size 不吻合，这意味着 Android 并不会去做 heap 中的碎片整理用来关闭空闲区域。Android 仅仅会在 heap 的尾端出现不使用的空间时才会做收缩逻辑 heap size大小的动作。但是这并不是意味着被 heap 所使用的物理内存大小不能被收缩。在垃圾回收之后，Dalvik会遍历heap并找出不使用的 pages，然后使用 madvise (系统调用)把那些 pages 返回给 kernal。因此，成对的 allocations 与 deallocations 大块的数据可以使得物理内存能够被正常的回收。然而，回收碎片化的内存则会使得效率低下很多，因为那些碎片化的分配页面也许会被其他地方所共享到。

##### 限制应用的内存

Android 为每一个 app 都设置了一个硬性的 heap size 限制。准确的 heap size 限制会因为不同设备的不同RAM大小而各有差异。如果你的 app 已经到了 heap 的限制大小并且再尝试分配内存的话，会引起`OutOfMemoryError`的错误。

在一些情况下，你也许想要查询当前设备的 heap size 限制大小是多少，然后决定 cache 的大小。可以通过`getMemoryClass()`来查询。这个方法会返回一个整数，表明你的应用的 heap size 限制是多少Mb(megabates)。

#### 你的应用该如何管理内存

* 珍惜 Service 资源(多用 IntentService)

* 当 UI 隐藏时释放内存(onTrimMemory())

  因为 onTrimMemory() 的回调是在 **API 14** 才被加进来的，对于老的版本，你可以使用 [onLowMemory](http://developer.android.com/reference/android/content/ComponentCallbacks.html#onLowMemory()) 回调来进行兼容。onLowMemory 相当与`TRIM_MEMORY_COMPLETE`。

* 当内存紧张时释放部分内存

* 检查你应该使用多少的内存

* 避免 bitmaps 的浪费

* 使用优化的数据容器(例如[SparseArray](http://developer.android.com/reference/android/util/SparseArray.html), [SparseBooleanArray](http://developer.android.com/reference/android/util/SparseBooleanArray.html), 与 [LongSparseArray](http://developer.android.com/reference/android/support/v4/util/LongSparseArray.html))

* 谨慎使用第三方 libraries

* 为序列化的数据使用 nano protobufs [Protocol buffers](https://developers.google.com/protocol-buffers/docs/overview)

http://hukai.me/android-training-managing_your_app_memory/



#### 电量

[Battery Historian ](https://developer.android.com/about/versions/android-5.0.html#Power)是Android 5.0开始引入的新API。通过下面的指令，可以得到设备上的电量消耗信息：

```shell
$ adb shell dumpsys batterystats > xxx.txt  //得到整个设备的电量消耗信息
$ adb shell dumpsys batterystats > com.package.name > xxx.txt //得到指定app相关的电量消耗信息
```

得到了原始的电量消耗数据之后，我们需要通过Google编写的一个[python脚本](https://github.com/google/battery-historian)把数据信息转换成可读性更好的 html 文件：

```shell
$ python historian.py xxx.txt > xxx.html
```

##### Track Battery Status & Battery Manager

获取手机当前充电状态：

```java
// It is very easy to subscribe to changes to the battery state, but you can get the current
// state by simply passing null in as your receiver.  Nifty, isn't that?
IntentFilter filter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
Intent batteryStatus = this.registerReceiver(null, filter);
int chargePlug = batteryStatus.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1);
boolean acCharge = (chargePlug == BatteryManager.BATTERY_PLUGGED_AC);
if (acCharge) {
    Log.v(LOG_TAG,“The phone is charging!”);
}
```

在上面的例子演示了如何立即获取到手机的充电状态，得到充电状态信息之后，我们可以有针对性的对部分代码做优化。比如我们可以判断只有当前手机为AC充电状态时 才去执行一些非常耗电的操作。

```java
/**
 * This method checks for power by comparing the current battery state against all possible
 * plugged in states. In this case, a device may be considered plugged in either by USB, AC, or
 * wireless charge. (Wireless charge was introduced in API Level 17.)
 */
private boolean checkForPower() {
    // It is very easy to subscribe to changes to the battery state, but you can get the current
    // state by simply passing null in as your receiver.  Nifty, isn't that?
    IntentFilter filter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
    Intent batteryStatus = this.registerReceiver(null, filter);

    // There are currently three ways a device can be plugged in. We should check them all.
    int chargePlug = batteryStatus.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1);
    boolean usbCharge = (chargePlug == BatteryManager.BATTERY_PLUGGED_USB);
    boolean acCharge = (chargePlug == BatteryManager.BATTERY_PLUGGED_AC);
    boolean wirelessCharge = false;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
        wirelessCharge = (chargePlug == BatteryManager.BATTERY_PLUGGED_WIRELESS);
    }
    return (usbCharge || acCharge || wirelessCharge);
}
```

##### Using Job Scheduler

使用[Job Scheduler](https://developer.android.com/reference/android/app/job/JobScheduler.html)，应用需要做的事情就是判断哪些任务是不紧急的，可以交给 Job Scheduler 来处理，Job Scheduler 集中处理收到的任务，选择合适的时间，合适的网络，再一起进行执行。

下面是使用 Job Scheduler 的一段简要示例，需要先有一个 JobService：

```java
public class MyJobService extends JobService {
    private static final String LOG_TAG = "MyJobService";

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(LOG_TAG, "MyJobService created");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.i(LOG_TAG, "MyJobService destroyed");
    }

    @Override
    public boolean onStartJob(JobParameters params) {
        // This is where you would implement all of the logic for your job. Note that this runs
        // on the main thread, so you will want to use a separate thread for asynchronous work
        // (as we demonstrate below to establish a network connection).
        // If you use a separate thread, return true to indicate that you need a "reschedule" to
        // return to the job at some point in the future to finish processing the work. Otherwise,
        // return false when finished.
        Log.i(LOG_TAG, "Totally and completely working on job " + params.getJobId());
        // First, check the network, and then attempt to connect.
        if (isNetworkConnected()) {
            new SimpleDownloadTask() .execute(params);
            return true;
        } else {
            Log.i(LOG_TAG, "No connection on job " + params.getJobId() + "; sad face");
        }
        return false;
    }

    @Override
    public boolean onStopJob(JobParameters params) {
        // Called if the job must be stopped before jobFinished() has been called. This may
        // happen if the requirements are no longer being met, such as the user no longer
        // connecting to WiFi, or the device no longer being idle. Use this callback to resolve
        // anything that may cause your application to misbehave from the job being halted.
        // Return true if the job should be rescheduled based on the retry criteria specified
        // when the job was created or return false to drop the job. Regardless of the value
        // returned, your job must stop executing.
        Log.i(LOG_TAG, "Whelp, something changed, so I'm calling it on job " + params.getJobId());
        return false;
    }

    /**
     * Determines if the device is currently online.
     */
    private boolean isNetworkConnected() {
        ConnectivityManager connectivityManager =
                (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();
        return (networkInfo != null && networkInfo.isConnected());
    }

    /**
     *  Uses AsyncTask to create a task away from the main UI thread. This task creates a
     *  HTTPUrlConnection, and then downloads the contents of the webpage as an InputStream.
     *  The InputStream is then converted to a String, which is logged by the
     *  onPostExecute() method.
     */
    private class SimpleDownloadTask extends AsyncTask<JobParameters, Void, String> {

        protected JobParameters mJobParam;

        @Override
        protected String doInBackground(JobParameters... params) {
            // cache system provided job requirements
            mJobParam = params[0];
            try {
                InputStream is = null;
                // Only display the first 50 characters of the retrieved web page content.
                int len = 50;

                URL url = new URL("https://www.google.com");
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setReadTimeout(10000); //10sec
                conn.setConnectTimeout(15000); //15sec
                conn.setRequestMethod("GET");
                //Starts the query
                conn.connect();
                int response = conn.getResponseCode();
                Log.d(LOG_TAG, "The response is: " + response);
                is = conn.getInputStream();

                // Convert the input stream to a string
                Reader reader = null;
                reader = new InputStreamReader(is, "UTF-8");
                char[] buffer = new char[len];
                reader.read(buffer);
                return new String(buffer);

            } catch (IOException e) {
                return "Unable to retrieve web page.";
            }
        }

        @Override
        protected void onPostExecute(String result) {
            jobFinished(mJobParam, false);
            Log.i(LOG_TAG, result);
        }
    }
}
```

然后模拟通过点击Button触发N个任务，交给JobService来处理

```java
public class FreeTheWakelockActivity extends ActionBarActivity {
    public static final String LOG_TAG = "FreeTheWakelockActivity";

    TextView mWakeLockMsg;
    ComponentName mServiceComponent;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_wakelock);

        mWakeLockMsg = (TextView) findViewById(R.id.wakelock_txt);
        mServiceComponent = new ComponentName(this, MyJobService.class);
        Intent startServiceIntent = new Intent(this, MyJobService.class);
        startService(startServiceIntent);

        Button theButtonThatWakelocks = (Button) findViewById(R.id.wakelock_poll);
        theButtonThatWakelocks.setText(R.string.poll_server_button);

        theButtonThatWakelocks.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                    pollServer();
            }
        });
    }

    /**
     * This method polls the server via the JobScheduler API. By scheduling the job with this API,
     * your app can be confident it will execute, but without the need for a wake lock. Rather, the
     * API will take your network jobs and execute them in batch to best take advantage of the
     * initial network connection cost.
     *
     * The JobScheduler API works through a background service. In this sample, we have
     * a simple service in MyJobService to get you started. The job is scheduled here in
     * the activity, but the job itself is executed in MyJobService in the startJob() method. For
     * example, to poll your server, you would create the network connection, send your GET
     * request, and then process the response all in MyJobService. This allows the JobScheduler API
     * to invoke your logic without needed to restart your activity.
     *
     * For brevity in the sample, we are scheduling the same job several times in quick succession,
     * but again, try to consider similar tasks occurring over time in your application that can
     * afford to wait and may benefit from batching.
     */
    public void pollServer() {
        JobScheduler scheduler = (JobScheduler) getSystemService(Context.JOB_SCHEDULER_SERVICE);
        for (int i=0; i<10; i++) {
            JobInfo jobInfo = new JobInfo.Builder(i, mServiceComponent)
                    .setMinimumLatency(5000) // 5 seconds
                    .setOverrideDeadline(60000) // 60 seconds (for brevity in the sample)
                    .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY) // WiFi or data connections
                    .build();

            mWakeLockMsg.append("Scheduling job " + i + "!\n");
            scheduler.schedule(jobInfo);
        }
    }
}
```

