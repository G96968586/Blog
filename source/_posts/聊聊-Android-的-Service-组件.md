---
title: 聊聊 Android 的 Service 组件
date: 2016-09-15 23:18:09
categories: Android
tags:
---
Android 开发的同学都知道，Android 有四大组件，分别是 [Activity](https://developer.android.com/reference/android/app/Activity.html)、[Service](https://developer.android.com/reference/android/app/Service.html)、[BroadcastReceiver](https://developer.android.com/reference/android/content/BroadcastReceiver.html) 和 [ContentProvider](https://developer.android.com/reference/android/content/ContentProvider.html)。在这里，我想跟大家聊一聊 Service 组件，我们从头开始，包括什么是 Service？Service 有什么作用？怎么使用它？需要关注哪些性能问题？什么情况下使用它最合适？好，废话少说，马上进入主题。
<!-- more -->

直译过来，Service 就是服务。它跟 Activity 不同，没有界面，不直接与用户进行交互，是一个可以在后台长时间运行的应用组件。服务可以由其他应用组件来启动，也可以由系统来启动。当用户从你的应用切换到其他应用后，我们的服务仍然可以在后台继续运行，甚至有些情况下，你退出了应用，服务仍能继续运行。最典型的例子就是音乐播放器了，当你退出应用后，音乐还能继续播放。又比如钉钉和微信，只要你没有在系统里禁止掉它们，即使杀掉它们的应用进程，你还是能收到别人给你发的消息。事实上，当你杀掉一个应用的进程后，该应用包括后台服务就彻底完了，只不过微信和钉钉有自启策略，又把服务拉起来了，这样你才能实时收到消息。

我们一般会在 Service 里做什么呢？上面刚举了一个例子，可以在 Service 里播放音乐，这样当用户手机锁屏或者按了 Home 键回到桌面，我们的音乐仍然能处于播放状态。另外，我们会常在 Service 里处理一些网络请求(如文件上传/下载等)、执行文件 I/O 或与内容提供程序(ContentProvider)交互等。

Service 有两种启动方式：

* 通过 startService() 来启动
* 通过 bindService() 绑定服务启动

Service 跟 Activity 一样，有它自己的生命周期。上面两种方式启动的 Service，其生命周期是有一些区别的，看下面的图：

![](https://gw.alicdn.com/tps/TB1onGRLXXXXXcvXVXXXXXXXXXX-389-507.png)

左图是使用 startService() 所创建的服务的生命周期，右图是使用 bindService() 所创建的服务的生命周期。

服务的**整个生命周期**从调用 `onCreate()` 开始起，到 `onDestroy()` 返回时结束。与 Activity 类似，服务也在 `onCreate()` 中完成初始设置，并在`onDestroy()` 中释放所有剩余资源。例如，音乐播放服务可以在 `onCreate()` 中创建用于播放音乐的线程，然后在 `onDestroy()` 中停止该线程。无论服务是通过 `startService()` 还是 `bindService()` 创建，都会为所有服务调用 `onCreate()` 和 `onDestroy()` 方法。

服务的**有效生命周期**从调用 `onStartCommand()` 或 `onBind()` 方法开始。每种方法均有 `Intent` 对象，该对象分别传递到 `startService()` 或`bindService()`。

#### startService()

下面是一个普通的 Service 例子：

```java
public class LocalService extends Service {
    private static final String TAG = "LocalService";
    private NotificationManager mNM;

    // Unique Identification Number for the Notification.
    // We use it on Notification start, and to cancel it.
    private int NOTIFICATION = R.string.local_service_started;

    /**
     * Class for clients to access.  Because we know this service always
     * runs in the same process as its clients, we don't need to deal with
     * IPC.
     */
    public class LocalBinder extends Binder {
        LocalService getService() {
            return LocalService.this;
        }
    }

    public LocalService() {
    }

    // This is the object that receives interactions from clients.  See
    // RemoteService for a more complete example.
    private final IBinder mBinder = new LocalBinder();


    @Override
    public IBinder onBind(Intent intent) {
        Log.d(TAG, "onBind");
        return mBinder;
    }

    @Override
    public void onCreate() {
        Log.d(TAG, "onCreate");
        mNM = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);

        // Display a notification about us starting.  We put an icon in the status bar.
        showNotification();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "onStartCommand");
        Log.i("LocalService", "Received start id " + startId + ": " + intent);
        return START_NOT_STICKY;
    }

    @Override
    public void onStart(Intent intent, int startId) {
        Log.d(TAG, "onStart");
        super.onStart(intent, startId);
    }

    @Override
    public boolean onUnbind(Intent intent) {
        Log.d(TAG, "onUnbind");
        return super.onUnbind(intent);
    }

    @Override
    public void onDestroy() {
        Log.d(TAG, "onDestroy");
        // Cancel the persistent notification.
        mNM.cancel(NOTIFICATION);

        // Tell the user we stopped.
        Toast.makeText(this, R.string.local_service_stopped, Toast.LENGTH_SHORT).show();
    }

    /**
     * Show a notification while this service is running.
     */
    @TargetApi(16)
    private void showNotification() {
        // In this sample, we'll use the same text for the ticker and the expanded notification
        CharSequence text = getText(R.string.local_service_started);

        // The PendingIntent to launch our activity if the user selects this notification
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0,
                new Intent(this, OtherActivity.class), 0);

        // Set the info for the views that show in the notification panel.
        Notification notification = new Notification.Builder(this)
                .setSmallIcon(R.mipmap.ic_launcher)  // the status icon
                .setTicker(text)  // the status text
                .setWhen(System.currentTimeMillis())  // the time stamp
                .setContentTitle(getText(R.string.local_service_label))  // the label of the entry
                .setContentText(text)  // the contents of the entry
                .setContentIntent(contentIntent)  // The intent to send when the entry is clicked
                .build();

        // Send the notification.
        mNM.notify(NOTIFICATION, notification);
    }
}

```

Activity 用来启动和结束服务，具体代码如下：

```java
public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }

    public void start(View view) {
        Intent intent = new Intent(this, LocalService.class);
        startService(intent);// 这里我们先使用 startService 来启动服务
    }

    public void stop(View view) {
        Intent intent = new Intent(this, LocalService.class);
        stopService(intent);// 使用 startService 启动的服务，需要我们通过 stopService 来结束它
    }
}

```

XML 布局代码如下：

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:paddingBottom="@dimen/activity_vertical_margin"
    android:paddingLeft="@dimen/activity_horizontal_margin"
    android:paddingRight="@dimen/activity_horizontal_margin"
    android:paddingTop="@dimen/activity_vertical_margin"
    tools:context="com.xhj.huijian.servicedemo.MainActivity">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello World!"
        android:id="@+id/textView"/>

    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="startService"
        android:onClick="start"
        android:id="@+id/button"
        android:layout_below="@+id/textView"
        android:layout_alignParentLeft="true"
        android:layout_alignParentStart="true"/>

    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="stopService"
        android:onClick="stop"
        android:id="@+id/button2"
        android:layout_below="@+id/button"
        android:layout_alignParentLeft="true"
        android:layout_alignParentStart="true"/>
</RelativeLayout>

```

如同 Activity（以及其他组件）一样，您必须在应用的清单文件(AndroidManifest.xml)中声明所有服务。需要添加 [`<service>`](https://developer.android.com/guide/topics/manifest/service-element.html) 元素作为 [`<application>`](https://developer.android.com/guide/topics/manifest/application-element.html) 元素的子元素。例如：

```xml
<manifest ... >
  ...
  <application ... >
      <service android:name=".service.LocalService" />
      <activity>...</activity>
      <activity>...</activity>
      ...
  </application>
</manifest>
```

service 标签有一些常见的选项，我在这里也跟大家罗列一下：

```xml
<service
            android:name=".service.LocalService"
            android:exported="false"
            android:enabled="true"
            android:label="@string/local_service_label"
            android:icon="@mipmap/ic_launcher"
            android:permission=""
            android:process=":process">
        </service>
```

```
android:name:　服务类名
android:label: 这个属性用于设定一个要显示给用户的服务的名称。如果没有设置这个属性，则会使用<application>元素的label属性值来代替。
android:icon: 这个属性定义了一个代表服务的图标，它必须要引用一个包含图片定义的可绘制资源。如果这个属性没有设置，则会使用<application>元素的icon属性所设定的图标来代替。
android:permission: 申明此服务的权限，这意味着只有提供了该权限的应用才能控制或连接此服务
android:process: 表示该服务是否运行在另外一个进程，如果设置了此项，那么将会在包名后面加上这段字符串表示另一进程的名字
android:enabled: 这个属性用于指示该服务是否能够被实例化。如果设置为true，则能够被实例化，否则不能被实例化。默认值是true。
android:exported： 表示该服务是否能够被其他应用程序所控制或连接，不设置默认此项为 false
```

OK，大家可以看到，前面我在 LocalService 的每一个生命周期方法中都添加了 log 打印，这样方便我们在跑 demo 时看到效果。现在请先忽视 LocalBinder 这个类。当服务通过 startService 启动后，我在 onCreate() 里调用了 showNotification() 方法，这时候会在系统状态栏看到一条消息：

![](https://gw.alicdn.com/tps/TB1GIa9LXXXXXXSXpXXXXXXXXXX-970-236.png)

如果你点击它，则会打开一个新的 Activity，简单的显示一条招呼内容：

![](https://gw.alicdn.com/tps/TB1FRSPLXXXXXXYaXXXXXXXXXXX-980-324.png)

从前面的生命周期图中，我们可以知道，当我们启动一个服务后，它会依次调用 onCreate -> onStartCommand 方法，我们看下日志输出：

![](https://gw.alicdn.com/tps/TB1zG93LXXXXXaxXFXXXXXXXXXX-2266-190.png)

因为我在 onStartCommand 里多打印了一条 log，

```java
Log.i("LocalService", "Received start id " + startId + ": " + intent);
```

所以在 onStartCommand 后面多了一条日志：

```shell
Received start id 1: Intent { cmp=com.xhj.huijian.servicedemo/.service.LocalService }
```

如果这时候，我再重新去启动这个服务，它是不会再走 onCreate 这个方法的，但会重复调用 onStartCommand 方法，从上图的日志就可以看出来啦，系统又打印了两条 log:

```shell
07-31 01:42:11.928 11361-11361/com.xhj.huijian.servicedemo D/LocalService: onStartCommand
07-31 01:42:11.928 11361-11361/com.xhj.huijian.servicedemo I/LocalService: Received start id 2: Intent { cmp=com.xhj.huijian.servicedemo/.service.LocalService }
```

此时，我在主 Activity 点击了 stop 按钮结束服务，LocalService 就会调用 onDestory 方法并结束掉自己。

#### bindService()

现在，我们通过第二种方式 bindService()  来启动服务。首先，在主 Activity 的布局里我们添加一个 bindService 按钮，另其 android:onClick="bind" ，并在主 Activity 实现 bind 方法，这样当你点击 bindService 按钮时 bind 方法就会被触发，这是 Android 另一种事件绑定的方式。 bindService 绑定 Service 之前，我们还需要去实现一个 ServiceConnection，它用来监视 Activity (client) 与 service 的连接状态。当创建了一个可以绑定的 service 之后，你必须提供一个 [IBinder](http://developer.android.com/reference/android/os/IBinder.html) 对象，它用来提供 Activity (client) 与service 进行交互的接口。前面我们提到的 LocalBinder 就是一个 IBinder 对象了。

回顾一下 LocalService ，有下面的一段代码，

```java
/**
     * Class for clients to access.  Because we know this service always
     * runs in the same process as its clients, we don't need to deal with
     * IPC.
     */
    public class LocalBinder extends Binder {
        LocalService getService() {
            return LocalService.this;
        }
    }

    public LocalService() {
    }

    // This is the object that receives interactions from clients.  See
    // RemoteService for a more complete example.
    private final IBinder mBinder = new LocalBinder();


    @Override
    public IBinder onBind(Intent intent) {
        Log.d(TAG, "onBind");
        return mBinder;
    }
```

在 onBind 方法里返回一个 IBinder 对象。

在 MainActivity 里实现 ServiceConnection 的代码如下：

```java
private LocalService mBoundService;
private boolean mIsBound = false;

private ServiceConnection mConnection = new ServiceConnection() {
  		// 绑定成功时回调该方法
        public void onServiceConnected(ComponentName className, IBinder service) {
            // This is called when the connection with the service has been
            // established, giving us the service object we can use to
            // interact with the service.  Because we have bound to a explicit
            // service that we know is running in our own process, we can
            // cast its IBinder to a concrete class and directly access it.
            mBoundService = ((LocalService.LocalBinder)service).getService();

            // Tell the user about this for our demo.
            Toast.makeText(MainActivity.this, R.string.local_service_connected,
                    Toast.LENGTH_SHORT).show();
        }
		// 解绑时回调该方法
        public void onServiceDisconnected(ComponentName className) {
            // This is called when the connection with the service has been
            // unexpectedly disconnected -- that is, its process crashed.
            // Because it is running in our same process, we should never
            // see this happen.
            mBoundService = null;
            Toast.makeText(MainActivity.this, R.string.local_service_disconnected,
                    Toast.LENGTH_SHORT).show();
        }
    };

// 添加绑定和解绑方法
void doBindService() {
        // Establish a connection with the service.  We use an explicit
        // class name because we want a specific service implementation that
        // we know will be running in our own process (and thus won't be
        // supporting component replacement by other applications).
        bindService(new Intent(MainActivity.this,
                LocalService.class), mConnection, Context.BIND_AUTO_CREATE);
        mIsBound = true;
    }

    void doUnbindService() {
        if (mIsBound) {
            // Detach our existing connection.
            unbindService(mConnection);
            mIsBound = false;
        }
    }

// 在 bind 方法里调用 doBindService
public void bind(View view) {
        doBindService();
    }
// 在 Activity 的 onDestory 方法里解绑
@Override
    protected void onDestroy() {
        super.onDestroy();
        doUnbindService();
    }
```

bindService 比 startService 多了两个参数，需要传入 ServiceConnection 对象和一个绑定的选项，这里我们传入了 Context.BIND_AUTO_CREATE，表示只要有绑定存在，就自动创建服务(automatically create the service as long as the binding exists)。上面的代码，我们还在 Activity 的 onDestory 方法里调用了 doUnbindService 方法去解绑服务，事实上，当一个 client(这里指 Activity) 销毁后，即使我们没有在 onDestory 里进行解绑，被绑定的服务也会一同被销毁，因为系统会自动为我们解绑。这一点跟 startService 启动的服务不同，使用 startService 启动的服务，如果在 Activity 被销毁时没有调用 stopService()，服务还将在后台运行(如果是应用进程被杀掉，服务也就挂了)。

启动绑定服务并退出应用，可以看到下面的日志输出：

![](https://gw.alicdn.com/tps/TB1CUbjLXXXXXXeXXXXXXXXXXXX-1230-130.png)

依次调用了 onCreate -> onBind -> onUnbind -> onDestory 方法，这验证了前面说的使用 bindService 创建服务的生命周期。那如果我们重复 bindService 呢？其生命周期是否会发生改变？事实是，onCreate 和 onBind 都不会重复调用。

当我们需要允许组件与服务进行交互、发送请求、获取结果，甚至是利用进程间通信 (IPC) 跨进程执行这些操作时，就需要绑定服务提供一个客户端(client)-服务器(service)接口了。换句话说，通常是需要给其他程序组件提供服务时才会使用 bindService。

上面所说的都是本地服务(local service) ，即服务跑在应用主进程中。有本地自然就有远程啦，接下来，我们来了解远程服务 (remote service) 是什么样的。

#### RemoteService(AIDL)

远程服务运行在独立的进程中，对应进程名格式为所在包名加上你指定的 android:process 字符串，前面介绍 service 标签常见选项时有提到过。比如，我有一个应用的包名是：com.example.servicedemo，我在其中一个 service 里添加了下面的属性 android:process=":process"，这时候，这个服务就会运行在一个名叫 com.example.servicedemo:process 的进程中。由于是独立的进程，因此在 Activity 所在进程被Kill 的时候，该服务依然在运行，不受其他进程影响，有利于为多个进程提供服务具有较高的灵活性。

远程服务一般都是系统服务，并且都是常驻服务，Android 上第三方的消息推送服务，也都是跑在独立进程中的。

远程服务涉及到不同进程之间的通信(IPC，interprocess communication)，需要使用到 AIDL(Android Interface Definition Language)，用于生成可以在 Android 设备上两个进程之间进行进程间通信的代码。说到这里，你应该知道远程服务需要通过绑定来启动了。下面我们动起手，使用 AIDL 创建一个远程服务。

首先，我们另起一个 Android 工程 AIDLServer，用来充当跨进程通信的服务端，然后创建一个 .aidl 文件。在 AS 里创建 AIDL 很简单，在工程的 java 目录下，右键你的包名，选择 New -> AIDL -> AIDL File，

![](https://gw.alicdn.com/tps/TB1S9yYLXXXXXayapXXXXXXXXXX-847-417.png)

我们将其命名为 IRemoteService，然后就会在 main 目录下出现一个 aidl 跟 java 同级别的目录，如图：

![](https://gw.alicdn.com/tps/TB1Qqe1LXXXXXckaXXXXXXXXXXX-434-214.png)

在 IRemoteService.aidl 添加一个 getPid() 方法，代码如下：

```java
// IRemoteService.aidl
package com.xhj.huijian.aidlserver;

// Declare any non-default types here with import statements

interface IRemoteService {
    /** Request the process ID of this service, to do evil things with it. */
    int getPid();

    /**
     * Demonstrates some basic types that you can use as parameters
     * and return values in AIDL.
     */
    void basicTypes(int anInt, long aLong, boolean aBoolean, float aFloat,
            double aDouble, String aString);
}
```

说明一下，aidl 中支持的参数类型为：基本类型（int, long, char, boolean 等）,String, CharSequence, List, Map，其他类型必须使用 import 导入，即使它们可能在同一个包里。另外，接口中的参数除了 aidl 支持的类型，其他类型必须标识其方向：输入、输出或两者兼之，用 in，out 或者 inout 来表示，默认为 in。

我们可以在工程 app -> build -> generated -> source -> aidl -> debug 下看到 AS 为我们自动生成了一个接口 IRemoteService，

![](https://gw.alicdn.com/tps/TB1LnPcLXXXXXaWXFXXXXXXXXXX-434-267.png)

打开 IRemoteService 可以看到一个代理类

```java
public static abstract class Stub extends android.os.Binder implements com.xhj.huijian.aidlserver.IRemoteService
```

这个 Stub 类就是一个普通的 Binder，只不过它实现了我们定义的 aidl 接口。它还有一个静态方法

```java
/**
 * Cast an IBinder object into an com.xhj.huijian.aidlserver.IRemoteService interface,
 * generating a proxy if needed.
 */
public static com.xhj.huijian.aidlserver.IRemoteService asInterface(android.os.IBinder obj)
```

通过它，我们就可以在客户端中得到 IRemoteService 的实例，进而通过实例来调用其方法。现在，我们创建一个服务端的 service，在里面去实现 aidl 中的抽象函数，代码如下：

```java
public class ServerService extends Service {
    private static final String TAG = "ServerService";
    private static final String PACKAGE_PERMISSION = "com.xhj.huijian.servicedemo";
    private NotificationManager mNM;

    // Unique Identification Number for the Notification.
    // We use it on Notification start, and to cancel it.
    private int NOTIFICATION = R.string.remote_service_started;

    public ServerService() {
    }
    // 实现 aidl 中的抽象函数
    private final IRemoteService.Stub mBinder = new IRemoteService.Stub() {
        @Override
        public int getPid() throws RemoteException {
            // 这里返回进程 ID
            return Process.myPid();
        }

        @Override
        public void basicTypes(int anInt, long aLong, boolean aBoolean, float aFloat, double aDouble, String aString) throws RemoteException {
            // Does nothing
        }

        // 在这里可以做权限认证，return false 意味着客户端的调用就会失败，比如下面，只允许包名为 com.xhj.huijian.servicedemo 的客户端通过，
        // 其他 apk 将无法完成调用过程
        @Override
        public boolean onTransact(int code, Parcel data, Parcel reply, int flags) throws RemoteException {
            String packageName = null;
            String[] packages = ServerService.this.getPackageManager().
                    getPackagesForUid(getCallingUid());
            if (packages != null && packages.length > 0) {
                packageName = packages[0];
            }
            Log.d(TAG, "onTransact: " + packageName);
            if (!PACKAGE_PERMISSION.equals(packageName)) {
                return false;
            }
            return super.onTransact(code, data, reply, flags);
        }
    };

    @Override
    public void onCreate() {
        Log.d(TAG, "remote service onCreate");
        mNM = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);

        // Display a notification about us starting.  We put an icon in the status bar.
        showNotification();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "remote service onStartCommand");
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public IBinder onBind(Intent intent) {
        Log.d(TAG, "remote service onBind");
        return mBinder;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        Log.d(TAG, "remote service onUnbind");
        return super.onUnbind(intent);
    }

    @Override
    public void onRebind(Intent intent) {
        super.onRebind(intent);
        Log.d(TAG, "remote service onRebind");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "remote service onDestroy");
        // Cancel the persistent notification.
        mNM.cancel(NOTIFICATION);

        // Tell the user we stopped.
        Toast.makeText(this, R.string.remote_service_stopped, Toast.LENGTH_SHORT).show();
    }

    /**
     * Show a notification while this service is running.
     */
    @TargetApi(16)
    private void showNotification() {
        // In this sample, we'll use the same text for the ticker and the expanded notification
        CharSequence text = getText(R.string.remote_service_started);

        // The PendingIntent to launch our activity if the user selects this notification
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0,
                new Intent(this, MainActivity.class), 0);

        // Set the info for the views that show in the notification panel.
        Notification notification = new Notification.Builder(this)
                .setSmallIcon(R.mipmap.ic_launcher)  // the status icon
                .setTicker(text)  // the status text
                .setWhen(System.currentTimeMillis())  // the time stamp
                .setContentTitle(getText(R.string.remote_service_label))  // the label of the entry
                .setContentText(text)  // the contents of the entry
                .setContentIntent(contentIntent)  // The intent to send when the entry is clicked
                .build();

        // Send the notification.
        mNM.notify(NOTIFICATION, notification);
    }
}
```

ServerService 中 new 了一个 IRemoteService.Stub 对象，并实现了其抽象方法，然后在 onBind 方法返回给 client，这不难理解。在这里我要说的是在 IRemoteService.Stub 里被我们重写的 onTransact 方法，在该方法中可以根据调用者的 uid 来获取其信息，然后做权限认证，如果返回 true，则调用成功，否则调用会失败。这样我们的服务就可以做到只让某个特定的 apk 使用，而不是所有的 apk 都能使用。

接下来，在 AndroidMenifest 中声明我们的服务，

```xml
 <service
            android:name=".ServerService"
            android:process=":remote"
            android:enabled="true"
            android:exported="true">
            <intent-filter>
                <category android:name="android.intent.category.DEFAULT" />
                <action android:name="com.xhj.huijian.aidlserver.ServerService" />
            </intent-filter>
        </service>
```

```xml
<action android:name="com.xhj.huijian.aidlserver.ServerService" />
```

这一句是为了让其他应用通过隐式的方式来 bind 我们的 Service。通过隐式调用的方式来起 activity 或者service，需要把 category 设为 default，这是因为，隐式调用的时候，intent 中的 category 默认会被设置为default。这里需要注意的是，exported 要设置为 true，否则其他应用就绑定不了我们的服务了。

现在回到我们的“客户端”，第一个工程，在 MainActivity 里我们稍加一些测试代码：

```java
...
// action，隐式调用
private static final String ACTION_BIND_SERVICE = "com.xhj.huijian.aidlserver.ServerService";
private IRemoteService mIRemoteService;

// 远程服务 ServiceConnection
    private ServiceConnection mRemoteConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
            mIRemoteService = IRemoteService.Stub.asInterface(iBinder);
            int pid = 0;
            try {
                pid = mIRemoteService.getPid();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            Log.d(TAG, "process id : " + pid);
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            mIRemoteService = null;
        }
    };

// 添加一个启动远程服务进程的 button，设置 onClick = bindRemoteService
public void bindRemoteService(View view) {
        Intent intent = new Intent(ACTION_BIND_SERVICE);
        intent.setPackage("com.xhj.huijian.aidlserver");
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        bindService(intent, mRemoteConnection, Context.BIND_AUTO_CREATE);
    }

@Override
    protected void onDestroy() {
        super.onDestroy();
	    ...
        if (mIRemoteService != null) {
            unbindService(mRemoteConnection);
        }
    }
```

和前面一样，我们绑定服务前要声明一个 ServiceConnection，我们在 onServiceConnected 方法里去获取 IRemoteService 的实例，然后调用它的方法 getPid 打印出一条 log，这里需要 try catch 一下捕获异常。在写 demo 时我遇到了一个问题，原本在 bindRemoteService 里我是这样写的：

```java
public void bindRemoteService(View view) {
        Intent intent = new Intent(ACTION_BIND_SERVICE);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        bindService(intent, mRemoteConnection, Context.BIND_AUTO_CREATE);
    }
```

少了这一行代码 intent.setPackage("com.xhj.huijian.aidlserver"); 然后在运行 demo 时发生了 crash，错误日志有这么一句，

```shell
IllegalArgumentException: Service Intent must be explicit
```

经查阅资料发现，在 Android 5.0 以后服务必须采用显示方式启动，刚好我的模拟器就是 5.0 的，醉了。不过，方法还是有的，就是加上那句设置应用包名的代码，这是 Google 推荐的解决方法。OK，先安装好服务端，然后打开客户端，点击绑定远程服务按钮，可以看到系统状态栏弹出了一条消息，效果图如下：

![](https://gw.alicdn.com/tps/TB1sXnpLXXXXXalXFXXXXXXXXXX-996-314.png)

从日志可以看出，我们调用 ServerService 的 getPid 方法成功了，输出了 process id : 16822

![](https://gw.alicdn.com/tps/TB1lvPfLXXXXXbXXVXXXXXXXXXX-1350-54.png)

下面是 ServerService 的生命周期，跟本地服务绑定的生命周期一个样。

![](https://gw.alicdn.com/tps/TB1qFTqLXXXXXXZXFXXXXXXXXXX-1762-166.png)

如果 AIDL 所支持的参数类型不满足我们的需求，我们想传输自定义类型的对象，该怎么做呢？

首先，在 AIDLServer 工程新建一个 Rect.aidl (名字随便起一个) 文件，

```java
// Rect.aidl
package com.xhj.huijian.aidlserver;

// Declare any non-default types here with import statements
parcelable Rect;
```

这里 parcelable 是个类型，首字母是小写的，和 Parcelable 接口不是一个东西。

Rect.java 代码如下：

```java
public final class Rect implements Parcelable{
    public int left;
    public int top;
    public int right;
    public int bottom;

    public Rect() {

    }

    private Rect(Parcel in) {
        readFromParcel(in);
    }

    public static final Creator<Rect> CREATOR = new Creator<Rect>() {
        @Override
        public Rect createFromParcel(Parcel in) {
            return new Rect(in);
        }

        @Override
        public Rect[] newArray(int size) {
            return new Rect[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int i) {
        parcel.writeInt(left);
        parcel.writeInt(top);
        parcel.writeInt(right);
        parcel.writeInt(bottom);
    }

    public void readFromParcel(Parcel in) {
        left = in.readInt();
        top = in.readInt();
        right = in.readInt();
        bottom = in.readInt();
    }
}
```

通过 AIDL 传输非基本类型的对象，被传输的对象需要序列化，Android sdk 提供了更轻量级更方便的方法，即实现 Parcelable 接口，上面就是一个去实现 Parcelable 接口的例子。你需要去实现一些抽象方法，还有 Parcelable.CREATOR 接口。

回到 IRemoteService.aidl，往里面添加一些代码：

```java
// IRemoteService.aidl
package com.xhj.huijian.aidlserver;
import com.xhj.huijian.aidlserver.Rect;
// Declare any non-default types here with import statements

interface IRemoteService {
    /** Request the process ID of this service, to do evil things with it. */
    int getPid();

    /**
     * Demonstrates some basic types that you can use as parameters
     * and return values in AIDL.
     */
    void basicTypes(int anInt, long aLong, boolean aBoolean, float aFloat,
            double aDouble, String aString);

    List<com.xhj.huijian.aidlserver.Rect> getRect();
    void addRect(in com.xhj.huijian.aidlserver.Rect rect);
}

```

新增了两个方法 getRect() 和 addRect(in Rect rect)，前面提到过，除了 aidl 支持的类型外，其他类型都必须标识其方向，这里 addRect 方法参数用 in 标记，因为它是输入型参数。

ServerService 做了一些修改，代码如下：

```java
private List<Rect> mRects = new ArrayList<>();
...
private final IRemoteService.Stub mBinder = new IRemoteService.Stub() {
        @Override
        public int getPid() throws RemoteException {
            // 这里返回进程 ID
            return Process.myPid();
        }

        @Override
        public void basicTypes(int anInt, long aLong, boolean aBoolean, float aFloat, double aDouble, String aString) throws RemoteException {
            // Does nothing
        }

  	    // 实现两个新增的方法
        @Override
        public List<Rect> getRect() throws RemoteException {
            synchronized (mRects) {
                return mRects;
            }
        }

        @Override
        public void addRect(Rect rect) throws RemoteException {
            synchronized (mRects) {
                if (!mRects.contains(rect)) {
                    mRects.add(rect);
                }
            }
        }
...
@Override
    public void onCreate() {
        Log.d(TAG, "remote service onCreate");
        mNM = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);

        // Display a notification about us starting.  We put an icon in the status bar.
        showNotification();
        // 初始化一些数据
        synchronized (mRects) {
            for (int i = 0; i < 5; i++) {
                Rect rect = new Rect();
                rect.top = i * 1;
                rect.left = i * 2;
                rect.right = i * 4;
                rect.bottom = i * 8;
                mRects.add(rect);
            }
        }
    }
```

因为我们增加了两个文件，Rect.aidl 和 Rect.class，所以也需要把这个两个文件拷贝到客户端中去。把 Rect.aidl 放在跟 IRemoteService 同目录下，在客户端工程(ServiceDemo)新建一个包，名为 com.xhj.huijian.aidlserve， Rect.class 在服务端的包名一样。客户端的 MainActivity 我们也修改一下调用代码，

```java
// 远程服务 ServiceConnection
    private ServiceConnection mRemoteConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
            mIRemoteService = IRemoteService.Stub.asInterface(iBinder);
            int pid = 0;
            Rect rect = null;
            try {
                pid = mIRemoteService.getPid();
                // 因为第一个元素的四个属性值都是0，所以我在这里取 rect 数组的第二个元素
                rect = mIRemoteService.getRect().get(1);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            Log.d(TAG, "process id : " + pid);
            Log.d(TAG, "rect top : " + rect.top + " right : " + rect.right + " left : "
            + rect.left + " bottom : " + rect.bottom);
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            mIRemoteService = null;
        }
    };
```

OK，重新 run 一下工程，点击绑定按钮，可以看到下面的日志输出，

![](https://gw.alicdn.com/tps/TB120DxLXXXXXbTXpXXXXXXXXXX-1696-60.png)

大功告成！是不是觉得 AIDL 实现起来稍微麻烦了些啊？反正我是觉得挺烦的，那下面就给大家介绍不用 AIDL 实现 IPC 的一个简便方法。嘿，请别喷我，这只是一个简便方法。

大概的思路如下：

- Service 实现一个 Handler 来接受 Client 的每一个 callback。
- 这个 Handler 用来创建 Messenger 对象。
- Messenger 创建一个 IBinder 对象，Service 在 onBind 方法里面把这个对象返回给客户端。
- 客户端使用这个 IBinder 对象来实例化 Messenger (that references the service’s Handler), 然后客户端使用这个 messager 再发送 message 对象给 service。
- Service 在它的 handler 里面接收到每一个 Message。

直接上代码，代码演示了 client 和 service 怎么进行交互的。

Service 代码(AIDLServer)：

```java
public class MessageService extends Service {
    private static final String TAG = "MessageService";
    /** For showing and hiding our notification. */
    NotificationManager mNM;
    /** Keeps track of all current registered clients. */
    ArrayList<Messenger> mClients = new ArrayList<Messenger>();
    /** Holds last value set by a client. */
    int mValue = 0;

    /**
     * Command to the service to register a client, receiving callbacks
     * from the service.  The Message's replyTo field must be a Messenger of
     * the client where callbacks should be sent.
     */
    static final int MSG_REGISTER_CLIENT = 1;

    /**
     * Command to the service to unregister a client, ot stop receiving callbacks
     * from the service.  The Message's replyTo field must be a Messenger of
     * the client as previously given with MSG_REGISTER_CLIENT.
     */
    static final int MSG_UNREGISTER_CLIENT = 2;

    /**
     * Command to service to set a new value.  This can be sent to the
     * service to supply a new value, and will be sent by the service to
     * any registered clients with the new value.
     */
    static final int MSG_SET_VALUE = 3;

    /**
     * Handler of incoming messages from clients.
     */
    class IncomingHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MSG_REGISTER_CLIENT:
                    mClients.add(msg.replyTo);
                    Log.d(TAG, "register_client");
                    break;
                case MSG_UNREGISTER_CLIENT:
                    mClients.remove(msg.replyTo);
                    Log.d(TAG, "unregister_client");
                    break;
                case MSG_SET_VALUE:
                    Log.d(TAG, "set_value");
                    mValue = msg.arg1;
                    for (int i = mClients.size()-1; i >= 0; i--) {
                        try {
                            mClients.get(i).send(Message.obtain(null,
                                    MSG_SET_VALUE, mValue, 0));
                        } catch (RemoteException e) {
                            // The client is dead.  Remove it from the list;
                            // we are going through the list from back to front
                            // so this is safe to do inside the loop.
                            mClients.remove(i);
                        }
                    }
                    break;
                default:
                    super.handleMessage(msg);
            }
        }
    }

    /**
     * Target we publish for clients to send messages to IncomingHandler.
     */
    final Messenger mMessenger = new Messenger(new IncomingHandler());

    public MessageService() {
    }

    @Override
    public void onCreate() {
        super.onCreate();
        mNM = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);
        // Display a notification about us starting.
        showNotification();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        // Cancel the persistent notification.
        mNM.cancel(R.string.remote_service_started);
        // Tell the user we stopped.
        Toast.makeText(this, R.string.remote_service_stopped, Toast.LENGTH_SHORT).show();
    }

    /**
     * When binding to the service, we return an interface to our messenger
     * for sending messages to the service.
     */
    @Override
    public IBinder onBind(Intent intent) {
        return mMessenger.getBinder();
    }

    /**
     * Show a notification while this service is running.
     */
    @TargetApi(16)
    private void showNotification() {
        // In this sample, we'll use the same text for the ticker and the expanded notification
        CharSequence text = getText(R.string.remote_service_started);
        // The PendingIntent to launch our activity if the user selects this notification
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0,
                new Intent(this, MainActivity.class), 0);
        // Set the info for the views that show in the notification panel.
        Notification notification = new Notification.Builder(this)
                .setSmallIcon(R.mipmap.ic_launcher)  // the status icon
                .setTicker(text)  // the status text
                .setWhen(System.currentTimeMillis())  // the time stamp
                .setContentTitle(getText(R.string.remote_service_label))  // the label of the entry
                .setContentText(text)  // the contents of the entry
                .setContentIntent(contentIntent)  // The intent to send when the entry is clicked
                .build();
        // Send the notification.
        // We use a string id because it is a unique number.  We use it later to cancel.
        mNM.notify(R.string.remote_service_started, notification);
    }
}
```

在 AndroidManifest 中注册，

```xml
<service
            android:name=".MessageService"
            android:enabled="true"
            android:exported="true"
            android:process=":remote_msg">
            <intent-filter>
                <category android:name="android.intent.category.DEFAULT"/>
                <action android:name="com.xhj.huijian.aidlserver.MessageService"/>
            </intent-filter>
        </service>
```

在客户端工程新建一个 MessageActivity，代码如下：

```java
public class MessageServiceActivity extends AppCompatActivity {
    private static final String ACTION_BIND_SERVICE = "com.xhj.huijian.aidlserver.MessageService";
    /** Messenger for communicating with service. */
    Messenger mService = null;
    /** Flag indicating whether we have called bind on the service. */
    boolean mIsBound;
    /** Some text view we are using to show state information. */
    TextView mCallbackText;

    /**
     * Command to the service to register a client, receiving callbacks
     * from the service.  The Message's replyTo field must be a Messenger of
     * the client where callbacks should be sent.
     */
    static final int MSG_REGISTER_CLIENT = 1;

    /**
     * Command to the service to unregister a client, ot stop receiving callbacks
     * from the service.  The Message's replyTo field must be a Messenger of
     * the client as previously given with MSG_REGISTER_CLIENT.
     */
    static final int MSG_UNREGISTER_CLIENT = 2;

    /**
     * Command to service to set a new value.  This can be sent to the
     * service to supply a new value, and will be sent by the service to
     * any registered clients with the new value.
     */
    static final int MSG_SET_VALUE = 3;

    /**
     * Handler of incoming messages from service.
     */
    class IncomingHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MessageServiceActivity.MSG_SET_VALUE:
                    mCallbackText.setText("Received from service: " + msg.arg1);
                    break;
                default:
                    super.handleMessage(msg);
            }
        }
    }

    /**
     * Target we publish for clients to send messages to IncomingHandler.
     */
    final Messenger mMessenger = new Messenger(new IncomingHandler());

    private ServiceConnection mConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
            // This is called when the connection with the service has been
            // established, giving us the service object we can use to
            // interact with the service.  We are communicating with our
            // service through an IDL interface, so get a client-side
            // representation of that from the raw service object.
            mService = new Messenger(iBinder);
            mCallbackText.setText("Attached.");

            Message msg = Message.obtain(null, MSG_REGISTER_CLIENT);
            msg.replyTo = mMessenger;
            try {
                mService.send(msg);
                msg = Message.obtain(null, MSG_SET_VALUE, this.hashCode(), 0);
                mService.send(msg);
            } catch (RemoteException e) {
                // In this case the service has crashed before we could even
                // do anything with it; we can count on soon being
                // disconnected (and then reconnected if it can be restarted)
                // so there is no need to do anything here.
            }
            // As part of the sample, tell the user what happened.
            Toast.makeText(MessageServiceActivity.this, R.string.remote_service_connected,
                    Toast.LENGTH_SHORT).show();
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            // This is called when the connection with the service has been
            // unexpectedly disconnected -- that is, its process crashed.
            mService = null;
            mCallbackText.setText("Disconnected.");

            // As part of the sample, tell the user what happened.
            Toast.makeText(MessageServiceActivity.this, R.string.remote_service_disconnected,
                    Toast.LENGTH_SHORT).show();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_message_service);
        // Watch for button clicks.
        Button button = (Button)findViewById(R.id.bind);
        button.setOnClickListener(mBindListener);
        button = (Button)findViewById(R.id.unbind);
        button.setOnClickListener(mUnbindListener);

        mCallbackText = (TextView)findViewById(R.id.callback);
        mCallbackText.setText("Not attached.");
    }

    void doBindService() {
        Intent intent = new Intent(ACTION_BIND_SERVICE);
        intent.setPackage("com.xhj.huijian.aidlserver");
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        bindService(intent, mConnection, Context.BIND_AUTO_CREATE);
        mIsBound = true;
        mCallbackText.setText("Binding.");
    }

    void doUnbindService() {
        if (mIsBound) {
            // If we have received the service, and hence registered with
            // it, then now is the time to unregister.
            if (mService != null) {
                try {
                    Message msg = Message.obtain(null, MSG_UNREGISTER_CLIENT);
                    msg.replyTo = mMessenger;
                    mService.send(msg);
                } catch (RemoteException e) {
                    // There is nothing special we need to do if the service
                    // has crashed.
                }
            }

            // Detach our existing connection.
            unbindService(mConnection);
            mIsBound = false;
            mCallbackText.setText("Unbinding.");
        }
    }

    private View.OnClickListener mBindListener = new View.OnClickListener() {
        public void onClick(View v) {
            doBindService();
        }
    };

    private View.OnClickListener mUnbindListener = new View.OnClickListener() {
        public void onClick(View v) {
            doUnbindService();
        }
    };
}
```

代码我就不再解释了，我贴下运行效果截图，

![](https://gw.alicdn.com/tps/TB1QwznLXXXXXXRaXXXXXXXXXXX-998-378.png)

已经收到来自 service 的消息啦，哈哈，从日志也可以看出我们已经成功访问了，

![](https://gw.alicdn.com/tps/TB1_nDALXXXXXXYXFXXXXXXXXXX-1594-110.png)

#### IntentService

刚开始学习 Android 开发时，常听人这么说，为了避免在 UI 线程上做耗时的操作所带来的 ANR(Application Not Responding)，可以把耗时的任务都放在 service 里去。其实这句话是不对的，在 service 里做耗时的操作同样也会带来 ANR。所以，你应该在 service 里开启子线程来执行耗时的任务。事实上，你不用自己那么麻烦地去创建一个 service，然后还要去管理 Service 的生命周期以及子线程。Android SDK 给你提供了一个叫 **IntentService** 的服务，它是 service 的子类，使用工作线程逐一处理所有启动请求。如果您不要求服务同时处理多个请求，这是最好的选择。 您只需实现 `onHandleIntent()` 方法即可，该方法会接收每个启动请求的 Intent，使你能够执行后台工作。

在 IntentService 内维护着一个工作线程来处理耗时操作，启动 IntentService 的方式和启动传统 Service 一样，同时，当任务执行完后，IntentService 会自动停止，而不需要我们去手动控制。另外， IntentService 可以启动多次，而每一个耗时操作会以工作队列的方式在IntentService 的 onHandleIntent 回调方法中执行，并且，每次只会执行一个工作线程，执行完第一个再执行第二个，以此类推。

而且，所有请求都在一个单线程中，不会阻塞应用程序的主线程（UI 线程），同一时间只处理一个请求。

综述，使用 IntentService 至少会给我们带来两个好处，一方面不需要自己去创建和管理子线程了；另一方面不需要考虑在什么时候关闭 Service 了。

下面，我们通过一个例子来学习 IntentService 的使用。IntentService 是一个抽象类，我们需要去实现它的 onHandleIntent 方法，代码如下：

```java
public class UploadService extends IntentService {
    private static final String TAG = "UploadService";
    // IntentService can perform, e.g. ACTION_FETCH_NEW_ITEMS
    public static final String ACTION_UPLOAD = "com.xhj.huijian.servicedemo.service.action.UPLOAD";

    public static final String EXTRA_IMG_PATH = "com.xhj.huijian.servicedemo.service.extra.IMG_PATH";

    public UploadService() {
        super("UploadService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        if (intent != null) {
            final String action = intent.getAction();
            if (ACTION_UPLOAD.equals(action)) {
                final String path = intent.getStringExtra(EXTRA_IMG_PATH);
                handleUploadImg(path);
            }
        }
    }

    private void handleUploadImg(String path) {
        try {
            //模拟上传耗时
            Thread.sleep(2000);

            Intent intent = new Intent(MainActivity.UPLOAD_RESULT);
            intent.putExtra(EXTRA_IMG_PATH, path);
            sendBroadcast(intent);

        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "onCreate");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy");
    }
}

```

UploadService 是一个模拟上传图片的服务，代码很简单，不做过多的解释啦，看下 MainActivity 的代码，

```java
 private BroadcastReceiver uploadImgReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(UPLOAD_RESULT)) {
                String path = intent.getStringExtra(UploadService.EXTRA_IMG_PATH);
                uploadResult(path);
            }
        }
    };

private void uploadResult(String path) {
        TextView tv = (TextView) mContainer.findViewWithTag(path);
        tv.setText(path + " upload complete ");
    }
```

广播用来监听服务发送的消息，收到消息后修改页面上的控件内容，同步上传状态。

```java
public void startIntentService(View view) {
        String path = "/sdcard/images/" + (++img) + ".jpg";
        Intent intent = new Intent(this, UploadService.class);
        intent.setAction(UploadService.ACTION_UPLOAD);
        intent.putExtra(UploadService.EXTRA_IMG_PATH, path);
        startService(intent);

        TextView tv = new TextView(this);
        mContainer.addView(tv);
        tv.setText(path + " is uploading ...");
        tv.setTag(path);
    }
```

上面是启动一个服务区下载图片，同时在页面上添加一个 TextView 用于显示上传状态。下面代码展示了广播的注册和注销，

```java
@Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mContainer = (LinearLayout) findViewById(R.id.container);
        // 注册广播
        IntentFilter filter = new IntentFilter();
        filter.addAction(UPLOAD_RESULT);
        registerReceiver(uploadImgReceiver, filter);
    }


```

```java
 @Override
    protected void onDestroy() {
        super.onDestroy();
        ...
        // 注销广播
        unregisterReceiver(uploadImgReceiver);
    }
```

OK, Run 一下 demo，看下效果图：

![](https://gw.alicdn.com/tps/TB1ZoYLLXXXXXcZXpXXXXXXXXXX-497-746.gif)

#### 扩展 Service 类

上面所述，使用 IntentService 简化了启动服务的实现。但是，若要求服务执行多线程（而不是通过工作队列处理启动请求），则可扩展 service 类来处理每个 Intent。

下面我们创建一个并发处理多线程的 service，我们将其命名为 MultiThreadingService 吧，具体代码如下：

```java
public class MultiThreadingService extends Service {
    private Looper mServiceLooper;
    private ServiceHandler mServiceHandler;
    public static final String ACTION_MULTI_UPLOAD = "com.xhj.huijian.servicedemo.service.action.MULTI_UPLOAD";

    public static final String EXTRA_IMG_PATH = "com.xhj.huijian.servicedemo.service.extra.IMG_PATH";

    // Handler that receives messages from the thread
    private final class ServiceHandler extends Handler {
        public ServiceHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(Message msg) {
            try {
                //模拟上传耗时
                Thread.sleep(((int)(1 + Math.random() * 3)) * 1000);

                Intent intent = new Intent(MainActivity.UPLOAD_RESULT);
                intent.putExtra(EXTRA_IMG_PATH, (String) msg.obj);
                sendBroadcast(intent);
                stopSelf(msg.arg1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public MultiThreadingService() {
    }

    @Override
    public void onCreate() {
        // Start up the thread running the service.  Note that we create a
        // separate thread because the service normally runs in the process's
        // main thread, which we don't want to block.  We also make it
        // background priority so CPU-intensive work will not disrupt our UI.
        HandlerThread thread = new HandlerThread("ServiceStartArguments",
                Process.THREAD_PRIORITY_BACKGROUND);
        thread.start();

        // Get the HandlerThread's Looper and use it for our Handler
        mServiceLooper = thread.getLooper();
        mServiceHandler = new ServiceHandler(mServiceLooper);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, final int startId) {
        Toast.makeText(MultiThreadingService.this, "多线程服务启动", Toast.LENGTH_SHORT).show();
        if (intent != null) {
            final String action = intent.getAction();
            if (TextUtils.equals(action, ACTION_MULTI_UPLOAD)) {
                final String path = intent.getStringExtra(EXTRA_IMG_PATH);
                // 取消下面的注释, 然后注销掉下面的 Thread,该服务的作用就跟 UploadService 一样了
//                Message msg = mServiceHandler.obtainMessage();
//                msg.arg1 = startId;
//                msg.obj = path;
//                mServiceHandler.sendMessage(msg);

                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            //模拟上传耗时
                            Thread.sleep(((int)(1 + Math.random() * 3)) * 1000);

                            Intent intent = new Intent(MainActivity.UPLOAD_RESULT);
                            intent.putExtra(EXTRA_IMG_PATH, path);
                            sendBroadcast(intent);
                            stopSelf(startId);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    }
                }).start();
            }
        }
        // If we get killed, after returning from here, restart
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        Toast.makeText(MultiThreadingService.this, "多线程服务结束", Toast.LENGTH_SHORT).show();
    }
}

```

因为我们自己处理了 `onStartCommand()` 的每个调用，因此可以同时执行多个请求。Activity 的代码我就不贴出来了，大家看下 demo 吧，运行上面的代码，随便点击几下 "MultiService" 按钮，就可以看到下图的效果了，

![](https://gw.alicdn.com/tps/TB1J9.XLXXXXXcYaXXXXXXXXXXX-497-746.gif)

可以看出已经是并发线程下载了。

#### 前台服务

前台服务被认为是用户主动意识到的一种服务，因此在内存不足时，系统也不会考虑将其终止。前台服务必须为状态栏提供通知，状态栏位于“正在进行”标题下方，这意味着除非服务停止或从前台删除，否则不能清除通知。这个例子最好举了，当你打开音乐播放器时，你的手机状态栏上面是有一个通知，并且你手动去滑动是滑不掉的。

要请求让服务运行于前台，请调用 `startForeground()`。此方法取两个参数：唯一标识通知的整型数和状态栏的 `Notification`。例如：

```java
Notification notification = new Notification(R.drawable.icon, getText(R.string.ticker_text),
        System.currentTimeMillis());
Intent notificationIntent = new Intent(this, ExampleActivity.class);
PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);
notification.setLatestEventInfo(this, getText(R.string.notification_title),
        getText(R.string.notification_message), pendingIntent);
startForeground(ONGOING_NOTIFICATION_ID, notification);// 提供给 startForeground() 的整型 ID 不得为 0
```

要从前台删除服务，请调用 `stopForeground()`。此方法取一个布尔值，指示是否也删除状态栏通知。 此方法绝对不会停止服务。 但是，如果您在服务正在前台运行时将其停止，则通知也会被删除。

#### 写在最后

写这篇文章的原因，一是作为自己对 service 组件的理解和应用做一次较全面的总结，二是帮助 Android 新人对 service 组件的学习有一个比较深刻的了解，三是方便自己遗忘，可以回头来查阅。上面较多的例子来自 Google 官方文档，所以你也能看到很多的英文注释，原本想把英文注释去掉，太占篇幅了，但后面发现，很多的英文注释可以帮助你理解代码为什么要这么写，因为注释很容易看，所以也不句句翻译了。当然，我也阅读了很多国内其他博主写的很好的博文，借鉴了他们的一些例子，之所以这么做，是怕自己个人的理解有些偏差，自己举例的代码不够好，误导大家。篇幅这么长，肯定有疏漏的地方，还请各位指出。

[附件 demo](http://download.csdn.net/detail/g96968586/9596505)
