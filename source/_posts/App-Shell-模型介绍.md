---
title: App Shell 模型介绍
date: 2017-11-29 15:35:43 
categories: PWA
tags: PWA
---
App Shell 是构建 PWA 的一种常用的技术方法，同时，App Shell 也是提高页面首次渲染速度的主流方法之一。通过 App Shell 我们的应用（Web App）能够做到像 Native App 一样可靠、即时地加载到用户设备屏幕上，极大的提高了用户体验。  
其实 App Shell 就是一个能够被缓存的、轻量级的界面框架，它往往是纯 HTML 片段，只包括内联 CSS 和 base64 图片，不依赖于 JS 框架，可以在加载、解析、执行 JS 之前就渲染出来，几乎消除了白屏时间，大大提高用户体验。  
结合服务工作线程 Service Worker 的 Cache API 缓存技术，App Shell 在没有网络或弱网络的情况下能表现的非常出色。它能够将一些初始 HTML 片段快速加载到屏幕上，并从缓存获取数据渲染到页面上，整个过程不需等待，带来了类似 Native App 的流畅过渡体验。  
![image | center](https://gw.alicdn.com/tfs/TB1CG2IdgMPMeJjy1XdXXasrXXa-743-550.png "")

## 构建自己的 App Shell
前面说过 App Shell 是一个轻量级界面框架，它将应用核心基础架构和 UI 同数据分离出来。因此，在构建我们的 App Shell 之前，需要明确区分页面 Shell 和动态数据。  
理想的 App Shell 具备下面的特点：
* 快速加载
* 尽可能使用较少的数据
* 使用本地静态缓存资源
* 将内容与页面导航分离开
* 检索和显示特定页面的内容（HTML、JSON 等）
* 缓存动态资源（可选）


这里有一个使用 App Shell 模型的 PWA 例子可以作为参考，Jake Archibald 的[离线维基百科应用](https://wiki-offline.jakearchibald.com/wiki/Rick_and_Morty)。它能在用户重复访问时即时加载到屏幕上，同时使用 JS 动态获取数据，并在稍后离线缓存数据内容，供后面访问使用。下面是截图示例。  
![image | center](https://gw.alicdn.com/tfs/TB1Q5g7dgMPMeJjy1XdXXasrXXa-1796-1280.jpg "")

### App Shell 的 HTML 示例
这里我们让示例应用初始加载时尽可能的简单，在访问示例应用时仅显示页面布局，至于数据，有些来自index 文件(内联 DOM、样式)，有些来自外部脚本、样式表。  
所有页面 UI 和基础架构都通过服务工作线程缓存在本地，这样，后面再次访问我们的应用时，将仅检索新数据或发生改变的数据，而不需要去加载所有的数据。  
下面是示例代码：
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>App Shell</title>
  <link rel="manifest" href="/manifest.json">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>App Shell</title>
  <link rel="stylesheet" type="text/css" href="styles/inline.css">
</head>

<body>
  <header class="header">
    <h1 class="header__title">App Shell</h1>
  </header>

  <nav class="nav">
  ...
  </nav>

  <main class="main">
  ...
  </main>

  <div class="dialog-container">
  ...
  </div>

  <div class="loader">
    <!-- Show a spinner or placeholders for content -->
  </div>

  <script src="app.js" async></script>
  <script>
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js').then(function(registration) {
      // Registration was successful
      console.log('ServiceWorker registration successful with scope: ', registration.scope);
    }).catch(function(err) {
      // registration failed :(
      console.log('ServiceWorker registration failed: ', err);
    });
  }
  </script>
</body>
</html>
```
其实就是一个普通的 HTML 页面，由于篇幅，这里把一些代码省略掉了。纵观整个页面，包括了下面三个部分：
* 页面主干：由 HTML 和 CSS 构成的页面导航以及一些内容展示块
* 用于处理导航和 UI 逻辑的外部 JavaScript 文件 app.js
* 网络应用清单 manifest.json 和用于启用离线功能的服务工作线程加载程序 sw.js


说到这，App Shell 也没有什么神秘的地方，简单理解就是 HTML 页面 + 逻辑处理文件 app.js + 服务工作线程 service-worker.js 。App Shell 也可以通过使用任意内容库或框架去编写。
### 缓存 App Shell
缓存 App Shell 实际上是通过服务工作线程来实现的。[《Service Workers 介绍》]() 以及[《调试 Service Workers》]() 都介绍过，这里就不多说了。
