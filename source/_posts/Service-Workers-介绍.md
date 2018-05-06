---
title: Service Workers 介绍
date: 2017-10-25 17:08:27
categories: PWA
tags: PWA
---

PWA 具备丰富的离线体验、定期的后台同步以及原生应用的推送通知功能，离不开 Service Workers 在背后提供的技术基础。
<!-- more -->
## 什么是 Service Workers
Service Workers，即服务工作线程，是浏览器在后台独立于网页运行的脚本，它不受页面窗口生命周期的限制。因为 Service Workers 是一种事件驱动型的 worker，生命周期与页面无关. 关联页面未关闭时, 它也可以退出, 没有关联页面时, 它也可以启动。
## Service Workers 生命周期
Service Workers 初始化安装时的简化生命周期图：  
![image | center](https://gw.alicdn.com/tfs/TB12CznbwMPMeJjy1XdXXasrXXa-702-685.png "")
  
Service Workers 生命周期的目的：
* 实现离线优先
* 在不打断现有 Service Workers 的情况下，准备好一个新的 Service Workers
* Service Workers 注册的作用域下的页面, 同一时间只由一个 Service Workers 控制
* 确保你的网站只有一个版本在运行


Service Workers 注册成功，即 `navigator.serviceWorker.register` 返回成功，并不意味着它已经完成安装或已经激活，只能说明 worker 的脚本被成功解析，此时处于 installing 状态，install 事件被触发，一般在 install 事件的回调处理函数中提前缓存相关的静态文件。

```javascript
var cacheName = 'xxx';
...
self.addEventListener('install', function(e) {
  e.waitUntil(
    caches.open(cacheName).then(function(cache) {
      console.log('[ServiceWorker] Caching app shell');
      return cache.addAll(filesToCache);
    })
  );
});
```
如果文件缓存失败，那安装步骤将会失败，Service Workers 也无法激活。如果发生这种情况，也不必担心，它下次会再试一次。如果安装成功，Service Workers 将会进入 installed / waiting 状态，此时，已准备好接管页面已有的 Service Workers，从而控制页面。  
Service Workers 满足下面条件其中之一，就会进入 activating 状态：
* 当前没有 active worker 在运行
* 代码调用了 self.skipWaiting() 跳过 waiting 状态
* 用户关闭页面, 释放了当前处于 active 状态的 worker
* 系统在一定时间后释放了当前处于 active 状态的 worker


在 activating 状态，activate 事件被触发，一般在 activate 事件的回调处理函数中清除旧缓存。
```javascript
self.addEventListener('activate', function(event) {

  var cacheWhitelist = ['pages-cache-v1', 'blog-posts-cache-v1'];

  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.map(function(cacheName) {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
```
如果 Service Workers 激活成功，将会进入 activated 状态，此时，该 worker 将会对其作用域内的所有页面进行控制，可以处理一些功能事件, 比如 fetch, push, message。

```javascript
self.addEventListener('fetch', function(event) {  
  // Do stuff with fetch events
});

self.addEventListener('message', function(event) {  
  // Do stuff with postMessages received from document
});
```
Service Workers 对页面进行控制后，并不会一直保持着 Running 状态。它会处于两种状态的互换：
* 为了节省内存，不需要处理事件和消息的 Service Workers 会处于 Stopped 状态，即使关联页面未关闭
* 页面发出网络请求或消息后，Service Workers 会处于 Running 状态，处理 fetch 和 message 事件，即使全部关联文档都已关闭


## 先决条件
### 浏览器支持
目前除了 Chrome 之外，Firefox 和 Opera 也已经支持 Service Workers。Edge、Safari 当前正在开发中。[is ServiceWork ready](https://jakearchibald.github.io/isserviceworkerready/) 这里可以查看所有浏览器的支持情况。
### 需要 Https
本地开发可以通过 localhost 使用 Service Workers，但部署到线上环境需要服务器支持 Https。

## 注册 Service Workers
首先检查浏览器是否支持 Service Worker API ，如果支持，则注册 Service Worker。
```javascript
if ('serviceWorker' in navigator) {
    navigator.serviceWorker
             .register('./service-worker.js')
             .then(function() { 
			 	console.log('Service Worker Registered'); 
			 }).catch(function(err) {
				console.log('ServiceWorker registration failed: ', err);
    });
  }
```
页面正常加载时，就会调用 register()，注意 register 方法参数所传的脚本路径，这里注册的 service-worker.js 脚本位于根目录下，这意味着 Service Worker 的作用域将是整个来源。换句话说，Service Worker 将接收此网站上所有事项的 fetch 事件。如果我们在 /example/service-worker.js 处注册Service Worker 文件，则 Service Worker 将只能看到网址以 /example/ 开头（即 /example/page1/、/example/page2/）的页面的 fetch 事件。  
这时候可以通过在 Chrome 浏览器输入 chrome://inspect/#service-workers 来检查 Service Worker 是否已启用。

## 安装服务工作线程
前面提到过，Service Workers 注册成功，说明 service-worker.js 脚本被成功解析，此时处于 installing 状态，install 事件被触发，此时我们可以在 install 事件回调里决定想要缓存哪些文件。
```javascript
var cacheName = 'weatherPWA';
var filesToCache = [
  '/',
  '/styles/main.css',
  '/script/main.js'
];

self.addEventListener('install', function(event) {
  // Perform install steps
  event.waitUntil(
    caches.open(cacheName).then(function(cache) {
      console.log('[ServiceWorker] Caching app shell');
      return cache.addAll(filesToCache);
    })
  );
});
```
首先，我们需要通过 caches.open() 打开缓存并提供一个缓存名称。缓存打开后，我们便可调用 cache.addAll()，这个带有网址列表参数的方法随即从服务器获取文件，并将响应添加到缓存内。event.waitUntil() 方法带有 promise 参数并使用它来判断安装所花费的时间以及安装是否成功。

## 缓存和返回请求
Service Workers 激活后，开始处理一些功能事件。下面提供一个例子：
```javascript
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
这里添加了 fetch 事件的监听，在 event.respondWith() 里传入 caches.match() 方法，caches.match() 会对 fetch 请求事件进行分析，检查它是否位于缓存内，并从 Service Workers 所创建的任何缓存中查找缓存的结果。如果发现匹配的响应，就返回缓存的值，否则，将调用 fetch 发出网络请求，并将请求拿到的数据作为结果返回。  
如果希望连续缓存新请求，可以通过处理 fetch 请求的响应并将其添加到缓存来实现，如下所示。
```javascript
self.addEventListener('fetch', function(event) {
  event.respondWith(
    caches.match(event.request)
      .then(function(response) {
        // Cache hit - return response
        if (response) {
          return response;
        }

        // IMPORTANT: Clone the request. A request is a stream and
        // can only be consumed once. Since we are consuming this
        // once by cache and once by the browser for fetch, we need
        // to clone the response.
        var fetchRequest = event.request.clone();
		// 在 fetch 请求中添加对 .then() 的回调。
        return fetch(fetchRequest).then(
          function(response) {
            // 确保响应有效，检查并确保响应的状态为 200，确保响应类型为 basic，亦即由自身发起的请求。 这意味着，对第三方资产的请求不会添加到缓存
            if(!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // IMPORTANT: Clone the response. A response is a stream
            // and because we want the browser to consume the response
            // as well as the cache consuming the response, we need
            // to clone it so we have two streams.
            var responseToCache = response.clone();

            caches.open(CACHE_NAME)
              .then(function(cache) {
                cache.put(event.request, responseToCache);
              });

            return response;
          }
        );
      })
    );
});
```
## 更新 Service Workers
前面提到的 service-worker.js 会在什么情况下请求更新呢？一般有两种更新方式。
* 强制更新  
  距离上一次更新检查已超过24小时, 会忽略浏览器缓存, 强制到服务器更新一次
* 检查更新
  * 第一次访问作用域里的页面
  * 距离上一次更新检查已超过24小时
  * 有功能性事件发生, 比如 push, sync
  * 在 Service Worker URL 发生变化时调用了.register()方法
  * service-worker.js 的缓存时间已超出其头部的 max-age 设置的时间 (注: max-age 大于24小时, 会使用24小时作为其值).
  * service-worker.js 的代码只要有一个字节发生了变化, 就会触发更新, 将其视为“新服务工作线程”


一个新的 Service Worker 启动时，将会触发 install 事件，但由于旧的 Service Worker 仍然控制着当前的页面，因此，新的 Service Worker 进入了 waiting 状态。当网站上当前打开的页面关闭时，旧的 Service Worker 就会终止，新的 Service Worker 将会取得控制权，此时会触发 activate 事件。  
在 activate 回调中的一个常见任务是缓存管理。原因在于，如果在安装步骤中清除了任何旧的缓存，则继续控制所有当前页面的任何旧的 Service Worker 将突然无法从缓存中提供文件。  
举个例子，比如说我们有一个名为 ‘my-site-cache-v1’ 的缓存，我们想要将该缓存拆分为一个页面缓存和一个博文缓存。这就意味着在安装步骤中我们创建了两个缓存：‘pages-cache-v1’ 和 ‘blog-posts-cache-v1’，且在激活步骤中我们要删除旧的 ‘my-site-cache-v1’。

以下代码将执行此操作，具体做法为：遍历服务工作线程中的所有缓存，并删除未在缓存白名单中定义的任何缓存。
```javascript
self.addEventListener('activate', function(event) {

  var cacheWhitelist = ['pages-cache-v1', 'blog-posts-cache-v1'];

  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.map(function(cacheName) {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
```
## Service Workers 的退出
Service Workers 在什么情况下会被停止呢？

（1）ServiceWorker JS 有任何异常，都会导致 ServiceWorker 线程退出。包括但不限于，JS 文件存在语法错误， ServiceWorker 安装失败/ 激活失败，ServiceWorker JS 执行时出现未捕获的异常。

（2）ServiceWorker 功能事件处理完成，处于空闲状态，ServiceWorker 线程会自动退出。

（3）ServiceWorker JS 执行时间过长，ServiceWorker 线程会自动退出。比如， ServiceWorker JS 执行时间超过30秒，或 Fetch 请求在5分钟内还未完成。

（4）浏览器会周期性检查各个 ServiceWorker 线程是否可以退出， 一般在启动ServiceWorker线程时会检查一次。

（5）为了方便开发者调试， Chromium 进行了特殊处理， 在连上 devtools 之后，ServiceWorker 线程不会退出。

## 参考文档
[PWA系列 - Service Workers 生命周期](https://www.atatech.org/articles/78747)  
[Service Workers: an Introduction](https://developers.google.com/web/fundamentals/getting-started/primers/service-workers)

