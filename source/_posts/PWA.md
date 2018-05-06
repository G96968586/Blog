---
title: 学习搭建你的第一个 PWA
date: 2017-10-25 15:28:03
categories: Android
tags: PWA
---

什么是 PWA ？ PWA 有哪些特点？PWA 在国内的发展情况怎么样？相对传统的 web 页面，PWA 能够给我们带来更多什么优势？想了解这些问题，可以看看这篇文章[《下一代 Web 应用模型 —— Progressive Web App》](https://huangxuan.me/2017/02/09/nextgen-web-pwa/)。本文的目的是教你如何搭建一个 PWA 应用，带你从中了解到 PWA 的一些技术实现细节和注意事项。
<!-- more -->
## 准备工作
* Chrome 52 或更高版本
* 安装 [Web Server for Chrome](https://chrome.google.com/webstore/detail/web-server-for-chrome/ofhbbkphhbklhfoeikjpcbhemlocgigb?hl=zh-cn) ![image | center](https://gw.alicdn.com/tfs/TB1OkN2SpXXXXcJaFXXXXXXXXXX-350-228.png_100x100.jpg "")
  ，当然，或使用自己选择的网络服务器
* IDE 或文本编辑器
* 官方示例代码 [->传送门](https://github.com/googlecodelabs/your-first-pwapp/archive/master.zip)

## 解压代码
解压官方代码，你会发现在文件夹 your-first-pwapp-master 里有下面的目录结构：

├── [CONTRIBUTING.md](http://CONTRIBUTING.md)  
├── final  
├── LICENSE  
├── [README.md](http://README.md)  
├── resources  
├── step-02  
├── step-04  
├── step-05  
├── step-06  
├── step-07  
├── step-08  
├── work  
│    ├── favicon.ico  
│    ├── images  
│    ├── index.html -> 后面会提到的 App Shell  
│    ├── scripts  
│    ├── styles
## 验证 Web Server for Chrome
首次安装完 Web Server for Chrome 后，打开它，会看到下面的窗口，  
![image | center](https://gw.alicdn.com/tfs/TB1kXGVSpXXXXXsXXXXXXXXXXXX-1728-1436.png_500x500.jpg "")

点击 choose folder 按钮，然后选择 work 文件夹，  
![image | center](https://gw.alicdn.com/tfs/TB1Ps5vSpXXXXcrXFXXXXXXXXXX-918-456.png_500x500.jpg "")

在 Options 下，选中“Automatically show index.html”旁边的框，如下所示：  
![image | center](https://gw.alicdn.com/tfs/TB1_fCvSpXXXXckXFXXXXXXXXXX-580-712.png_400x400.jpg "")

你也可以修改默认的端口号：8887  
然后将标记为“Web Server:STARTED”的切换按钮向左滑动，然后向右滑动，停止并重启服务器。  
现在打开 Chrome，按住 option + command + I 进入开发者工具模式，再按住 shift + command + M进入移动端模式，访问 [http://127.0.0.1:8887](http://127.0.0.1:8887) ，将会看到下面的页面，  
![image | center](https://gw.alicdn.com/tfs/TB1fzSJSpXXXXX7XpXXXXXXXXXX-758-1340.png_500x500.jpg "")

有一个转不停的菊花。
## 构建 App Shell
App Shell 是一个能够被缓存的、轻量级的界面框架，它往往是纯 HTML 片段，只包括内联 CSS 和 base64 图片，不依赖于 JS 框架，是确保获得可靠而又出色性能的组件之一。它的第一次加载速度非常快，并且能够立即缓存。“缓存”意味着 Shell 文件一旦通过网络完成加载，就会保存到本地设备中。以后每当用户打开应用时，就会自动从本地设备的缓存中打开 Shell 文件，这样应用就能超快启动。  
![image | center](https://gw.alicdn.com/tfs/TB1KXmVSpXXXXXBXXXXXXXXXXXX-1249-923.jpg "")

App Shell 将核心应用基础架构、 UI 与数据分离。所有 UI 和基础架构都利用服务工作线程缓存在本地，这样在后续加载时，PWA 只需检索必要的数据，而不必加载所有内容。换句话讲，App Shell 就类似于你在开发 Native 应用时需要向应用商店发布的一组代码。它是让你的应用成功起步所需的核心组件，但可能并不包含数据。
### 设计 App Shell
第一步是将设计细分成其核心组件。

问问自己：

* 哪些内容需要立即呈现在屏幕上？

* 还有哪些其他 UI 组件对我们的应用很重要？

* App Shell 需要哪些支持资源？例如图像、JavaScript、样式等。


示例代码是一个天气应用，将其作为我们的第一个 Progressive Web App。其关键组件将包括：

* 标头，其中包含标题和添加/刷新按钮
* 预报卡片容器
* 预报卡片模板
* 用于添加新城市的对话框
* 加载指示器


### 实现 App Shell

在示例代码 work 目录下，找到 index.html，这是一个实现好的 App Shell，里面已经完成了大部分的 UI，接下来，可以着手连接代码，让一切运转起来！

在 work 目录下找到 script/app.js，打开 app.js 可以找到以下内容：

* 一个 `app` 对象，其中包含应用所需的一些关键信息。
* 标头中所有按钮 (`add/refresh`) 和“Add City”对话框中所有按钮 (`add/cancel`) 的事件侦听器。
* 一个用于添加或更新预报卡片的方法 (`app.updateForecastCard`)。
* 一个用于从 Firebase Public Weather API 获取最新天气预报数据的方法 (`app.getForecast`)。
* 一个用于遍历现有卡片并调用 `app.getForecast` 以获取最新预报数据的方法 (`app.updateForecasts`)。
* 可用来快速测试渲染效果的一些虚假数据 (`initialWeatherForecast`)。


示例代码提供了 mock 的天气预报数据，为了了解数据是如何渲染的，我们取消 `index.html` 文件底部的以下行的注释：

```html
<!--<script src="scripts/app.js" async></script>-->
```

接下来，取消 `app.js` 文件底部的以下行的注释：

```javascript
// app.updateForecastCard(initialWeatherForecast);
```

刷新浏览器，你将看到如下图所示的界面：

![image | center](https://gw.alicdn.com/tfs/TB14XC0SpXXXXXHXXXXXXXXXXXX-754-1338.png_500x500.jpg "")


## 从快速首次加载开始

Progressive Web App 应启动迅速，并且立即就能使用。在目前状态下，我们的天气应用虽启动迅速，却无法使用，因为没有任何数据。我们可以发出 AJAX 请求来获取该数据，但那会额外增加一个请求，使首次加载时间变得更长。可以改为在首次加载时提供真实数据。

### 注入天气预报数据

在示例代码中，模拟服务器将天气预报直接注入 JavaScript 中，但在生产应用中，最新天气预报数据将由服务器根据用户的 IP 地址地理定位进行注入。

代码已经包含我们即将注入的数据。这就是前面步骤中使用的 `initialWeatherForecast`。

### 区分首次运行

我们怎么知道什么时候显示这些信息呢？因为未来加载时天气应用将从缓存中获取，届时这些信息可能不再相关了。比如，用户在后续访问时加载应用，他们可能已改换城市，因此，我们需要加载的是这些城市的信息，而不一定是他们查询过的第一个城市。

用户首选项（比如用户订阅的城市列表）应利用 IndexedDB 或其他快速存储机制存储在本地。为尽可能简化此代码实验室，我们使用了 [localStorage](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage)，但它并非生产应用的理想选择，因为它是一种封闭的同步存储机制，在某些设备上可能会运行得非常缓慢。

首先，让我们添加必要的代码来保存用户首选项。在 app.js 文件中，找到下面的 TODO 注释，

```javascript
 // TODO add saveSelectedCities function here
```

在注释下方添加下面的代码，

```javascript
// Save list of cities to localStorage.
  app.saveSelectedCities = function() {
    var selectedCities = JSON.stringify(app.selectedCities);
    localStorage.selectedCities = selectedCities;
  };
```

接下来，添加启动代码，以检查用户是否保存了任何城市并渲染这些城市，或使用注入的数据。找到以下注释：

```javascript
// TODO add startup code here
```

并在注释下方添加以下代码：

```javascript
/************************************************************************
   *
   * Code required to start the app
   *
   * NOTE:To simplify this codelab, we've used localStorage.
   *   localStorage is a synchronous API and has serious performance
   *   implications.It should not be used in production applications!
   *   Instead, check out IDB (https://www.npmjs.com/package/idb) or
   *   SimpleDB (https://gist.github.com/inexorabletash/c8069c042b734519680c)
   ************************************************************************/

  app.selectedCities = localStorage.selectedCities;
  if (app.selectedCities) {
    app.selectedCities = JSON.parse(app.selectedCities);
    app.selectedCities.forEach(function(city) {
      app.getForecast(city.key, city.label);
    });
  } else {
    /* The user is using the app for the first time, or the user has not
     * saved any cities, so show the user some fake data.A real app in this
     * scenario could guess the user's location via IP lookup and then inject
     * that data into the page.
     */
    app.updateForecastCard(initialWeatherForecast);
    app.selectedCities = [
      {key: initialWeatherForecast.key, label: initialWeatherForecast.label}
    ];
    app.saveSelectedCities();
  }
```

启动代码会检查本地存储中是否存储了任何城市。如果存储了城市，它就会解析本地存储数据，然后为保存的每个城市显示预报卡片。如果没有存储城市，启动代码会使用虚假的预报数据，并将其保存为默认城市。

最后，我们需要修改“Add City”按钮处理程序，以便将所选的城市添加到本地存储。

更新 `butAddCity` 点击处理程序，以便匹配以下代码：

```javascript
document.getElementById('butAddCity').addEventListener('click', function() {
    // Add the newly selected city
    var select = document.getElementById('selectCityToAdd');
    var selected = select.options[select.selectedIndex];
    var key = selected.value;
    var label = selected.textContent;
    if (!app.selectedCities) {
      app.selectedCities = [];
    }
    app.getForecast(key, label);
    app.selectedCities.push({key: key, label: label});
    app.saveSelectedCities();
    app.toggleAddDialog(false);
  });
```

新添加的内容是 `app.selectedCities` 的初始化，以及对 `app.selectedCities.push()` 和 `app.saveSelectedCities()` 的调用。

OK，再次刷新浏览器，运行时，应用应该会立即向用户显示来自 `initialWeatherForecast` 的天气预报数据。点击右上角的图标，增加新的城市，并验证应用是否加载了两个天气预报卡片并显示了最新信息。

## 利用 Service Worker 预缓存 App Shell

Progressive Web App 必须快速并且可安装，这意味着它们能够在在线、离线以及间歇性、弱网络连接下工作。要实现此目标，我们需要利用服务工作线程缓存我们的 App Shell，让其始终都能快速而又可靠地投入使用。

### 在服务工作线程可用时注册它

使应用离线工作的第一步是注册一个 Service Worker 服务工作线程，这是一个无需打开网页或用户交互便可实现后台功能的脚本。

只需要两步骤：

* 让浏览器将 JavaScript 文件注册为服务工作线程
* 创建包含此服务工作线程的 JavaScript 文件


首先我们需要检查浏览器是否支持服务工作线程，如果支持，则注册服务工作线程。在 app.js 找到下面注释之后

```javascript
// TODO add service worker code here
```

添加下面代码

```javascript
if ('serviceWorker' in navigator) {
    navigator.serviceWorker
             .register('./service-worker.js')
             .then(function() { console.log('Service Worker Registered'); });
  }
```

### 缓存网站资源

注册服务工作线程后，用户首次访问页面时将会触发安装事件。在此事件处理程序内，我们将缓存应用所需的全部资源。触发服务工作线程时，它会打开 [caches](https://developer.mozilla.org/en-US/docs/Web/API/Cache) 对象并为其填充加载 App Shell 所需的资源。在 work 目录下，创建 service-worker.js 文件，这个文件之所以必须位于应用的根文件夹内，是因为服务工作线程的作用域由该文件所在的目录定义。在 service-worker.js 添加下面代码，

```javascript
var cacheName = 'weatherPWA-step-6-1';
var filesToCache = [];

self.addEventListener('install', function(e) {
  console.log('[ServiceWorker] Install');
  e.waitUntil(
    caches.open(cacheName).then(function(cache) {
      console.log('[ServiceWorker] Caching app shell');
      return cache.addAll(filesToCache);
    })
  );
});

```

首先，我们需要通过 `caches.open()` 打开缓存并提供一个缓存名称。提供缓存名称可让我们对文件进行版本控制，或将数据与 App Shell 分开，以便我们能轻松地更新某个数据，而不会影响其他数据。

缓存打开后，我们便可调用 `cache.addAll()`，这个带有网址列表参数的方法随即从服务器获取文件，并将响应添加到缓存内。遗憾的是，`cache.addAll()` 具有原子性，如果任何一个文件失败，整个缓存步骤也将失败！

### 使用 DevTools 了解和调试服务工作线程

重新加载页面之前，打开 DevTools，转至 **Application **面板的 **Service Worker **窗口，如下所示：

![image | center](https://gw.alicdn.com/tfs/TB1it5fSpXXXXceapXXXXXXXXXX-632-419.png "")


如果看到类似于这样的空白页面，就表示当前打开的页面没有注册服务工作线程。

现在，重新加载页面。Service Worker 窗口现在应该像下面这样，表示页面正在运行服务工作线程。

![image | center](https://gw.alicdn.com/tfs/TB1jgh6SpXXXXayaVXXXXXXXXXX-1490-858.png_600x600 "")


现在，我们将要插入一点其他内容，说明我们在开发服务工作线程时可能会遇到的 Gotcha。为了说明这一问题，需要在 `service-worker.js` 文件中的 `install` 侦听器下面添加 `activate` 事件侦听器。

```javascript
self.addEventListener('activate', function(e) {
  console.log('[ServiceWorker] Activate');
});
```

`activate` 事件会在服务工作线程启动时触发。

打开 DevTools Console，重新加载页面，切换到 Application 面板中的 Service Worker 窗口，然后点击激活的服务工作线程上的 Inspect。可以看到 `[ServiceWorker] Activate` 消息记录到控制台，但并没有发生。请查看 Service Worker 窗口，我们会看到新的服务工作线程（包含激活事件侦听器）处于“等待”状态。

![image | center](https://gw.alicdn.com/tfs/TB1Hd1HSpXXXXa5XFXXXXXXXXXX-1494-534.png_600x600 "")


从根本上说，只要页面有打开的标签，以前的服务工作线程就会继续控制页面。因此，你可以关闭然后重新打开页面，或者按 **skipWaiting **按钮，但是更长期的解决方案只需启用 DevTools 的 Service Worker 窗口上的 **Update on Reload **复选框。如果启用此复选框，服务工作线程会在每次页面重新加载时强制更新。

现在启用 **update on reload **复选框，并重新加载页面，以确认新的服务工作线程被激活。

**注：** 你可能会在 Application 面板的 Service Worker 窗口中发到一个错误（类似于以下内容），完全可以忽略此错误。

![image | center](https://gw.alicdn.com/tfs/TB1v.KDSpXXXXcCXFXXXXXXXXXX-424-73.png "")


有关在 DevTools 中检查和调试服务工作线程的内容就到此结束。现在，我们来展开 `activate` 事件侦听器，添加以下逻辑来更新缓存。

```javascript
self.addEventListener('activate', function(e) {
  console.log('[ServiceWorker] Activate');
  e.waitUntil(
    caches.keys().then(function(keyList) {
      return Promise.all(keyList.map(function(key) {
        if (key !== cacheName) {
          console.log('[ServiceWorker] Removing old cache', key);
          return caches.delete(key);
        }
      }));
    })
  );
  return self.clients.claim();
});
```

上面代码可以确保我们的服务工作线程在任何 App Shell 文件更改时更新其缓存。为了使其工作，我们需要在服务工作线程文件的顶部增加 `cacheName` 变量。

最后，我们更新 App Shell 所需的文件列表。在数组中，我们需要加入应用所需的全部文件，包括图像、JavaScript、样式表等。在接近 `service-worker.js` 文件顶部的地方，使用以下代码替换 `var filesToCache = [];`

```javascript
var filesToCache = [
  '/',
  '/index.html',
  '/scripts/app.js',
  '/styles/inline.css',
  '/images/clear.png',
  '/images/cloudy-scattered-showers.png',
  '/images/cloudy.png',
  '/images/fog.png',
  '/images/ic_add_white_24px.svg',
  '/images/ic_refresh_white_24px.svg',
  '/images/partly-cloudy.png',
  '/images/rain.png',
  '/images/scattered-showers.png',
  '/images/sleet.png',
  '/images/snow.png',
  '/images/thunderstorm.png',
  '/images/wind.png'
];
```

现在应用现在还不能离线运行。我们虽然已缓存了 App Shell 组件，但仍需从本地缓存加载它们。

### 从缓存提供 App Shell

服务工作线程提供了拦截 Progressive Web App 发出的请求并在服务工作线程内对它们进行处理的能力。这意味着我们可以决定想要如何处理请求，并可提供我们自己的已缓存响应。

例如：

```javascript
self.addEventListener('fetch', function(event) {
  // Do something interesting with the fetch here
});
```

现在我们从缓存提供 App Shell。将以下代码添加到 `service-worker.js` 文件的底部：

```javascript
self.addEventListener('fetch', function(e) {
  console.log('[ServiceWorker] Fetch', e.request.url);
  e.respondWith(
    caches.match(e.request).then(function(response) {
      return response || fetch(e.request);
    })
  );
});
```

`caches.match()` 会由内而外对触发[ fetch ](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)事件的网络请求进行评估，并检查以确认它是否位于缓存内。它随即使用已缓存版本作出响应，或者利用 `fetch` 从网络获取一个副本。`response` 通过 `e.respondWith()` 传回至网页。

又到测试环节了，现在我们的应用可以离线运行了。重新加载页面，然后转至 DevTools 的 **Application** 面板的 **Cache Storage** 窗口。展开这个部分，可以看到左侧列出的 App Shell 缓存的名称。当我们点击 App Shell 缓存后，可以看到它当前缓存的所有资源。

![image | center](https://gw.alicdn.com/tfs/TB1EXiaSpXXXXabaFXXXXXXXXXX-1466-862.png_600x600 "")


现在，测试一下离线模式。回到 DevTools 的 **Service Worker** 窗口，然后勾上 **Offline** 复选框。启用后，可以看到 **Network** 面板标签旁边显示很小的黄色警告图标。这表示当前正处于离线状态。

![image | center](https://gw.alicdn.com/tfs/TB1Zo1oSpXXXXcdaXXXXXXXXXXX-1292-524.png_600x600 "")


重新刷新页面，你会发现天气预报卡片还是出来了！请注意它加载初始（虚假）天气数据的方式。

![image | center](https://gw.alicdn.com/tfs/TB1l3udSpXXXXbRapXXXXXXXXXX-752-898.png_400x400 "")


下一步就是修改应用和服务工作线程逻辑，以便能够缓存天气数据，并在应用处于离线状态时从缓存中返回最新数据。

如果要开始刷新和清除已保存的所有数据（localStoarge、indexedDB 数据、缓存文件）以及移除任何服务工作线程，请使用 Application 标签中的 Clear storage。

## 使用 Service Worker 缓存天气预报数据

### 拦截网络请求并缓存响应

我们需要修改服务工作线程，以拦截发给 weather API 的请求，并将其响应存储在缓存内，以便我们在稍后访问它们。

我们在服务工作线程中添加一个 `dataCacheName`，以便将应用数据与 App Shell 分离。更新 App Shell 并清除较旧缓存时，我们的数据将保持不变，可随时用于实现超快速加载。注意，如果未来你的数据格式发生变化，你需要相应的处理手段，并且需要确保 App Shell 和内容保持同步。

在 `service-worker.js` 文件顶部添加下面一行：

```javascript
var dataCacheName = 'weatherData-v1';
```

然后，更新 `activate` 事件处理程序，使其不会在清除 App Shell 缓存时删除数据缓存。

```javascript
if (key !== cacheName && key !== dataCacheName) {
```

最后，更新 `fetch` 事件处理程序，将发给 data API 的请求与其他请求分开处理。

```javascript
self.addEventListener('fetch', function(e) {
  console.log('[Service Worker] Fetch', e.request.url);
  var dataUrl = 'https://query.yahooapis.com/v1/public/yql';
  if (e.request.url.indexOf(dataUrl) > -1) {
    /*
     * When the request URL contains dataUrl, the app is asking for fresh
     * weather data. In this case, the service worker always goes to the
     * network and then caches the response. This is called the "Cache then
     * network" strategy:
     * https://jakearchibald.com/2014/offline-cookbook/#cache-then-network
     */
    e.respondWith(
      caches.open(dataCacheName).then(function(cache) {
        return fetch(e.request).then(function(response){
          cache.put(e.request.url, response.clone());
          return response;
        });
      })
    );
  } else {
    /*
     * The app is asking for app shell files. In this scenario the app uses the
     * "Cache, falling back to the network" offline strategy:
     * https://jakearchibald.com/2014/offline-cookbook/#cache-falling-back-to-network
     */
    e.respondWith(
      caches.match(e.request).then(function(response) {
        return response || fetch(e.request);
      })
    );
  }
});
```

以上代码会拦截请求，并检查网址是否以 weather API 的地址开头。如果是，我们将使用 [fetch](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) 发出请求。返回请求后，我们的代码会打开缓存，克隆响应，将其存储在缓存内，最后将响应返回给原始请求者。

我们的应用还不能完全离线工作。我们已经实现了 App Shell 的缓存和检索，但尽管我们缓存了数据，应用也没有查看缓存来看看其中是否有任何天气数据。

### 发出请求

如前面所述，应用需要发起两个异步请求，一个发向缓存，一个发向网络。应用利用 `window` 中提供的 `caches` 对象来访问缓存和检索最新数据。这是“渐进式增强”的一个典范，因为可能并非所有浏览器都提供 `caches` 对象，即使没有该对象，网络请求仍应正常工作。

为此，我们需要做的是：

1. 检查全局 `window` 对象中是否提供了 `caches` 对象
2. 从缓存请求数据
3. 如果服务器请求仍未完成，则用缓存的数据更新应用
4. 从服务器请求数据
5. 保存数据以便稍后快速访问
6. 使用来自服务器的最新数据更新应用


### 从缓存获取数据

接下来，我们需要检查并确保 `caches` 对象存在，并从该对象请求最新数据。找到 `app.getForecast()` 中的 `TODO add cache logic here` 注释，然后在注释下方添加以下代码。

```javascript
 if ('caches' in window) {
      /*
       * Check if the service worker has already cached this city's weather
       * data. If the service worker has the data, then display the cached
       * data while the app fetches the latest data.
       */
      caches.match(url).then(function(response) {
        if (response) {
          response.json().then(function updateFromCache(json) {
            var results = json.query.results;
            results.key = key;
            results.label = label;
            results.created = json.query.created;
            app.updateForecastCard(results);
          });
        }
      });
    }
```

我们的天气应用现在会发出两个异步数据请求，一个去请求 `cache` ，一个去请求远程 API 数据，一般情况下缓存请求会先把结果返回，此时我们的页面将以极快的速度（几十微秒）渲染，并更新卡片。随后，远程返回响应后将直接使用 weather API 的最新数据更新卡片。

请注意缓存请求和 XHR 请求都以更新预报卡片的调用结束。应用如何知道它是否显示了最新数据？`app.updateForecastCard` 中的以下代码会处理这个问题：

```javascript
var cardLastUpdatedElem = card.querySelector('.card-last-updated');
    var cardLastUpdated = cardLastUpdatedElem.textContent;
    if (cardLastUpdated) {
      cardLastUpdated = new Date(cardLastUpdated);
      // Bail if the card has more recent data then the data
      if (dataLastUpdated.getTime() < cardLastUpdated.getTime()) {
        return;
      }
    }
```

每次更新卡片时，应用都会在卡片上隐藏的属性中存储数据的时间戳。仅当卡片上已经存在的时间戳晚于传递给函数的数据时，应用才会释放。

现在应用应能完全离线运行了。保存两个城市，按应用上的 refresh 按钮获取最新的天气数据，然后转为离线状态并重新加载页面。

转至 DevTools 的 **Application** 面板的 **Cache Storage** 窗口。展开这个部分，你可以看到左侧列出的 App Shell 和数据缓存的名称。如果每个城市存储有数据，即可打开数据缓存。

![image | center](https://gw.alicdn.com/tfs/TB1mRGRSpXXXXaZXpXXXXXXXXXX-1662-816.png_600x600 "")


## 添加至主屏幕

通过 Add To Home Screen 功能，我们可以像从应用商店安装本机应用那样，选择为设备添加一个快捷链接，并且过程要顺畅得多。

### 通过 manifest.json 文件声明应用清单

网络应用清单是一个简单的 JSON 文件，利用网络应用清单，你的网络应用可以：

* 在用户的 Android 主屏幕进行丰富的呈现
* 在没有网址栏的 Android 设备上以全屏模式启动
* 控制屏幕方向以获得最佳查看效果
* 定义网站的“启动画面”启动体验和主题颜色
* 追踪你是从主屏幕还是从网址栏启动


在 work 文件夹中创建名称为 manifest.json 的文件，并复制/粘贴以下内容：

```json
{
  "name": "Weather",
  "short_name": "Weather",
  "icons": [{
    "src": "images/icons/icon-128x128.png",
      "sizes": "128x128",
      "type": "image/png"
    }, {
      "src": "images/icons/icon-144x144.png",
      "sizes": "144x144",
      "type": "image/png"
    }, {
      "src": "images/icons/icon-152x152.png",
      "sizes": "152x152",
      "type": "image/png"
    }, {
      "src": "images/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    }, {
      "src": "images/icons/icon-256x256.png",
      "sizes": "256x256",
      "type": "image/png"
    }],
  "start_url": "/index.html",
  "display": "standalone",
  "background_color": "#3E4EB8",
  "theme_color": "#2F3BA2"
}
```

此清单支持一组适用于各种屏幕尺寸的图标。

现在将以下行添加到 `index.html` 文件中的 `<head>` 元素底部：

```html
<link rel="manifest" href="/manifest.json">
```

最佳做法：

* 在你网站的所有网页上放置该清单链接，这样一来，无论用户首次访问时登陆哪个网页，Chrome 都会立即检索到它。
* 在 Chrome 上首选使用 `short_name`，如果存在，则优先于 name 字段使用。
* 为不同密度的屏幕定义图标集。Chrome 会尝试使用最接近 48dp 的图标，例如它会在 2 倍像素的设备上使用 96px，在 3 倍像素的设备上使用 144px。
* 请记得提供尺寸对启动画面而言合理的图标，并且别忘了设置 `background_color`。


在 `index.html` 中，向 `<head>` 元素底部添加以下代码，以适配 iOS Safari：

```html
<!-- Add to home screen for Safari on iOS -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Weather PWA">
  <link rel="apple-touch-icon" href="images/icons/icon-152x152.png">
```

测试验证，打开 DevTool，切换到 **Application **面板上的 **Manifest **窗口，

![image | center](https://gw.alicdn.com/tfs/TB1NzqASpXXXXcVXpXXXXXXXXXX-1894-1258.png_600x600 "")


发现浏览器已经将其解析出来了。切换到 Web Server for Chrome，勾上`Accessible on local network` 选项

![image | center](https://gw.alicdn.com/tfs/TB1rPOPSpXXXXXzXpXXXXXXXXXX-700-1212.png_600x600 "")


将网络服务器切换到 `STOPPED`，然后重新切换到 `STARTED`。你会看到在 Web Server URL(s) 下面有一个可以远程访问的地址，使用手机访问这个页面，就可以在手机上体验这个 PWA 了。

如果使用这种测试方式，你会在控制台中看到服务工作线程错误，这是因为未通过 HTTPS 提供服务工作线程。

在移动 Android 设备上使用 Chrome，尝试将应用添加到主屏幕并验证启动屏幕能否正确显示以及使用的图标是否正确。

## 部署到 Firebase

如果你从未接触过 Firebase，需要先创建你的帐户并安装一些工具。

1. 在 [https://firebase.google.com/console/](https://firebase.google.com/console/?hl=zh-cn) 上创建一个 Firebase 帐户
2. 通过 npm 安装 Firebase：`npm install -g firebase-tools`


创建帐户并登录后，便可随时进行部署！

1. 在 [https://firebase.google.com/console/](https://firebase.google.com/console/?hl=zh-cn) 上创建一个新应用，这里我创建了一个叫 PWA Demo 的应用

   ![image | center](https://gw.alicdn.com/tfs/TB1ly9fSpXXXXcBapXXXXXXXXXX-1970-566.png "")


2. 如果你近期未登录 Firebase 工具，需要重新登录：`firebase login`

3. 初始化你的应用，并提供你完成的应用所在的目录（我们的示例 Demo 是 `work`）： `firebase init`

   ![image | center](https://gw.alicdn.com/tfs/TB1QByCSpXXXXXHXVXXXXXXXXXX-2448-1328.png_600x600 "")


4. 最后，将应用部署到 Firebase： `firebase deploy`

   ![image | center](https://gw.alicdn.com/tfs/TB1Ahh6SpXXXXbeaVXXXXXXXXXX-2420-914.png_600x600 "")


5. 大功告成。 操作完成！我们的应用将部署到以下网域：`https://YOUR-FIREBASE-APP.firebaseapp.com`


测试，尝试将应用添加到主屏幕，然后断开网络并验证应用能够按照预期离线工作。当然，你可以选择部署到集团 CDN 上，这里就不演示了。

OK，就到这吧，后面再给大家带来详细的《调试服务工作线程》和 《向网络应用添加推送通知》的分享。

## 参考文档
https://developers.google.com/web/fundamentals/codelabs/your-first-pwapp/  
