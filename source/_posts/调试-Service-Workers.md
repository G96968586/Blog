---
title: 调试 Service Workers
date: 2017-11-29 15:35:21
categories: PWA
tags: PWA
---
这里我们来一起探讨如何使用 Chrome DevTools 中新增的 Application 面板调试和检查 Service Workers（服务工作线程）。
<!-- more -->
首先，你需要做一些准备工作，可以参考这篇[《搭建你的第一个 PWA》](https://lark.alipay.com/fgt-mobile/be9mcc/oeeik3)文章。为了便于调试，这里我们去 Google 实验室下载测试 Demo: [debugging-service-worker](https://github.com/googlecodelabs/debugging-service-workers/archive/master.zip)。
解压 Demo，打开 Web Server，点击 Choose Folder 将当前文件路径定位到 Demo 目录下的 work 目录。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/6b911bfcf3bcf47b.png)

我们然后关掉 Web Server，重新再打开，在 Chrome 地址栏输入 [http://127.0.0.1:8887](http://127.0.0.1:8887/) （当然，前提你没有更新 Web Server 默认的端口），你可以见到下图的页面。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/40be4c5b212b8e6e.png)

 

好了，进入我们的主题：Debuging Service Workers。

## Inspect Manifest

构建 PWA 需要结合多种不同的核心技术，包括 Service Workers、Network Manifest 以及有用的技术支持，比如由：Cache Storage API、IndexedDB、Push Notifications 。Chrome DevTools 给我们提供了 Application 调试窗口，并为每种技术提供了检查器，使我们能够轻松获得各种技术的协调视图。
回到前面的页面，打开 DevTools ，然后选中 Application。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/15fdfa68d4a7b572.png)

可以看到右边视图显示的是与 manifest.json 文件有关的重要信息，包括应用名称、启动网址、图标、图标大小等。你还可以发现这里有一个 **Add to homescreen** 按钮，它可用于模拟添加应用到用户主屏幕的效果。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/cbb979db1fdbbeb2.png)

## Inspect Service Workers

检查服务工作线程，首先选中 Manifest 下方的 Service Workers 菜单项，切换到 Service Workers 视图，

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/8b1f630f29fa4b88.png)

最顶部有四个复选框，Offline、Update on reload、Bypass for network 和 Show all。

- **Offline**：模拟断开网络连接。有助于快速验证服务工作线程的 fetch 事件是否正常运行。
- **Update on reload**：将用新的服务工作线程强制替换当前服务工作线程（如果开发者已更新`service-worker.js`）。通常情况下，浏览器不会强制替换，将进入等待状态，直到用户关闭包含当前网站的所有标签。
- **Bypass for network**：将强制浏览器忽略所有活动服务工作线程并从网络中获取资源。这有助于我们使用 CSS 或 JavaScript 而不需担心服务工作线程意外缓存或返回旧文件。
- **Show all**- 在不考虑来源的情况下，显示所有活动服务工作线程。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/6e1b168b208b2f6b.png)

 Status 字段显示当前服务工作线程的状态，绿色表示一切正常。绿色圆圈后面的数字是当前活动服务工作线程的 ID。橙色圆圈则代表有新的服务工作线程进入等待状态。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/fa8a52334757c2a4.png)

现在打开 work 目录下的 service-worker.js 文件，添加几行代码进去，

```
self.addEventListener('install', function(event) {
  console.log('Service Worker installing.');
});

self.addEventListener('activate', function(event) {
  console.log('Service Worker activating.');  
});
```

切换回 DevTools 窗口，刷新页面，可以看到控制台有日志输出，

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/8ca61141042f9492.png)

 再回到 service-worker.js 文件，我们修改一下打印的信息，

```
self.addEventListener('install', function(event) { 
    console.log('A new Service Worker is installing.'); 
});

self.addEventListener('activate', function(event) { 
    console.log('Finally active. Ready to start serving content!');
});
```

刷新页面看控制台输出信息，发现只输出了一句 “A new Service Worker is installing.”。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/707c8831d42cac1d.png)

 我们发现右边视图出现两个状态指示灯，前面提过橙色说明有新的服务工作线程进入等待状态，点击 skipWaiting 按钮强制激活新的服务工作线程。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/fa7fbe42997f12db.png)

这时候控制台输出了来自 activate 事件的处理消息 “Finally active. Ready to start serving content!”。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/677c034de2a9387a.png)

 我们也可以不必每次都点击 skipWaiting 按钮，只需要你勾选上 Update on reload，每次刷新页面浏览器都会强制最新的服务工作线程。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/49c682842694be19.png)

## Browser Cache

服务工作线程具备强大的离线缓存文件能力。**Application** 视图有很多有用的工具，用于浏览和修改存储的资源，这些工具在开发期间对我们非常有用。
为服务工作线程添加缓存，需要添加一些代码来存储一些文件。在服务工作线程的 install 阶段，预缓存文件是一种有用的技术，可以确保在用户即将离线时关键资源可用。
回到 service-worker.js 文件，更新代码如下：

```
var CACHE_NAME = 'my-site-cache-v1';
var urlsToCache = [
  '/',
  '/styles/main.css',
  '/scripts/main.js',
  '/images/smiley.svg'
];

self.addEventListener('install', function(event) {
  // Perform install steps
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function(cache) {
        return cache.addAll(urlsToCache);
      })
  );  
});

self.addEventListener('activate', function(event) {
  console.log('Finally active. Ready to start serving content!');  
});
```

刷新页面，在 Application 视图左边栏选中 Cache Storage 菜单项，

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/c161899c1a25be78.png)

点击 my-site-cache-v1，可以看到由服务工作线程缓存的所有文件。如果你需要从缓存中移除文件，可以右键点击该文件，然后从上下文菜单中选择 **delete **选项。同样，你也可以通过右键点击 my-site-cache-v1，然后选择 delete 删除整个缓存。
也许你已经注意到了，除 **Cache Storage**，还有一些与存储资源有关的其他菜单项：Local Storage、Session Storage、IndexedDB、Web SQL、Cookie 以及 Application Cache (“AppCache”)。在一个面板中精细控制每个资源是非常有用的！但是如果你想删除所有的存储资源，依次访问每个菜单项并删除其内容是相当繁琐的。更好的做法是，你可以使用 **Clear storage** 选项来一次性清理缓存（请注意这也将注销所有的服务工作线程）。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/ec0d649fc0854861.png)

什么是齿轮⚙️？
切换到 Network 视图，刷新页面，可以看到下面图示的结果，带有齿轮图标的是第二轮请求，这些请求似乎要获取相同的资源。那齿轮代表的是什么呢？

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/198bc2a7b8f1e974.png)

 齿轮图标表示这些请求来自服务工作线程本身。具体而言，这些是由服务工作线程的`install`处理程序提出以填充离线缓存的请求。

## 模拟不同网络条件

### 离线时提供请求服务

服务工作线程的杀手锏功能之一是即使在用户离线时，它们也能够为其提供缓存内容。要验证这一切是否正常运行，我们可以通过 Chrome 提供的一些网络节流工具来进行测试。
首先，在 service-worker.js 文件里添加下面代码，

```
self.addEventListener('fetch', function(event) {
  event.respondWith(
    caches.match(event.request)
      .then(function(response) {
        // Cache hit - return response
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
    )
  );
});
```

接着切换到 Application 视图，确保 Update on reload 处于勾选状态，刷新页面，重新安装新的服务工作线程，然后取消 Update on reload，勾选上 Offline 复选框。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/edaebdd8-bd67-4b31-9c9f-bf7562989b28.png)

你可以发现 Network 前面有一个黄色警告标志，表示当前已离线。这时候刷新页面，一切顺利的话，你应该还能看到整个网站内容。切换到 Network 视图，验证 Cache Storage 是否提供所有资源。这里的 Size 表示这些资源来自 `(from Service Worker)`。表明我们的服务工作线程拦截了请求，并提供了来自缓存的响应而不是来自网络。

 ![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/c5d6c262-a2d8-4507-b08f-32d187049603.png)

### 测试不同网络

目前很多地方 3G 和 2G 网络仍是常态。所以我们应该测试在这些弱网络的情况下，我们的应用是否还能保持高性能正常运行。

Chrome 提供了工具方便我们测试不同的网络情况。在 Application 视图下，取消 Offline，勾选上 Bypass for network。Bypass for network 将告诉浏览器，当需要发出网络请求时跳过我们的服务工作线程。这就意味着 Cache Storage 将不提供任何内容，就好像我们没有安装任何服务工作线程一样。

接下来，切换到 Network 视图，使用 Network Throttle 下拉菜单将网络速度设置为 Slow 3G。

 ![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/f9c71344-48a6-473d-9fa5-ba6136ef1774.png)

刷新页面，现在每个资源的下载需要 2 秒左右的时间。

 ![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/da7400ae-abe5-4adf-84fa-36bb379464aa.png)

现在，取消 Bypass for network，刷新页面，看看服务工作线程在后台运行时有何不同。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/fe9a1af5-00b4-4c90-9a3c-e70e2ff64892.png)

很明显，响应时间急速下降至每个资源仅需几毫秒。对于网络速度较慢的用户来说，这是天壤之别！

## 调试

服务工作线程实际上就是常规的 JavaScript 文件，我们可以使用现有的工具（如 debugger 语句和断点）来调试。

 现在我们来调试 install 处理程序。

在 service-worker.js 中 install 处理程序的开头添加一个 debugger 语句。

 ```
self.addEventListener('install', function(event) {
  debugger;
  // Perform install steps
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function(cache) {
        return cache.addAll(urlsToCache);
      })
  );  
});
 ```

切换到 Application 视图，刷新页面，点击 skipWaiting 激活新的服务工作线程。再次刷新页面触发 fetch 处理程序运行。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/0bf1ac58-5c29-4d7d-ab9e-398035751095.png)

页面自动跳转到 Sources 视图，并在 debugger 行处于暂停状态。右下方的 Scope 检查器，可以看到当前函数作用域内对象的当前状态。

点击 event:InstallEvent 下拉菜单，可以了解有关当前作用域内对象的各种有用的信息。例如，查看 type 字段，可以验证当前事件对象是否为 install 事件。

![img](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/2f188875-8250-49fd-bd50-0b88f7b5f31a.png)

当然，我们也可以使用断点来调试，这样会更加方便。

## 测试推送通知

也许你已经发现了页面中心有一个 **Subscribe for Push Notifications** 按钮，它要求用户订阅推送通知。此按钮已被远程配置，以在用户点击时请求推送通知权限。 

现在添加推送支持，打开 service-worker.js ，然后在 fetch 处理程序后添加以下几行，

```
self.addEventListener('push', function(event) {  
  var title = 'Yay a message.';  
  var body = 'We have received a push message.';  
  var icon = '/images/smiley.svg';  
  var tag = 'simple-push-example-tag';
  event.waitUntil(  
    self.registration.showNotification(title, {  
      body: body,  
      icon: icon,  
      tag: tag  
    })  
  );  
});
```

处理程序就绪后，就可以很轻松地模拟推送事件。切换到 Application 视图，刷新页面，点击 skipWaiting 按钮，安装最新服务工作线程，点击 Subscribe for Push Notifications 按钮，接收权限提示。

![img](https://developers.google.com/web/fundamentals/getting-started/codelabs/debugging-service-workers/img/a8a8fa8d35b0667a.png?hl=zh-cn)

最后，点击 **Update** 和 **Unregister** 旁边的 **Push** 按钮，现在应该会看到在屏幕的右上角，出现一个确认服务工作线程是否按预期处理 `push` 事件的推送通知。

![img](https://developers.google.com/web/fundamentals/getting-started/codelabs/debugging-service-workers/img/eacd4c5859f5f3ff.png?hl=zh-cn)

OK，本文就到这，后面带来《向网络应用添加推送通知》、Cache API 和构建 App Shell 有关的分享。