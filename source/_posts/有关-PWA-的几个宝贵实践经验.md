---
title: 有关 PWA 的几个宝贵实践经验
date: 2017-11-29 15:42:37 
categories: PWA
tags: PWA
---
日常的技术调研、新技术的尝鲜，我们更多的关注点是在技术本身上。但是，如果涉及到技术的具体落地，关联到线上生产环境，我们要考虑的因素就多了。这里以 PWA 为例，如果我们的产品使用了 PWA 技术，在将其部署到生产环境之前，我们需要做什么准备呢？需要提前考虑到哪些因素呢？下面是总结饿了么 M 站的一些宝贵实践经验，这里拿来跟大家分享。
## 提供降级方案
Service Worker 直接在浏览器网络层工作，脱离页面生命周期，提供资源预加载和强大的离线缓存能力，因此，如果 Service Worker 内部存在 bug，很大情况下 bug 会被放大，比如：
* 由于缓存的原因，bug 也被缓存起来了，不能及时的修复
* 如果 Service Worker 的缓存策略存在 bug，用户可能就无法更新页面了，这种情况开发者也不易察觉到
* Service Worker 的错误可能会导致整个页面无法工作，给业务带来灾难性的影响


而且，国内市面上各种各样的浏览器和系统，对 Service Worker 的能力支持各不相同，功能适配和兼容性问题给我们国内开发者写出 bug-free 代码带来了很大的难度。  
所以，万一出现重大 bug 了，怎么在最短时间内解决呢？当然是降级啦，所以提供降级方案非常有必要！那 PWA 怎么降级呢？  
[饿了么 M 站](http://chuansong.me/n/1676119852913) 提供了一个简单又粗暴的方法，就是降级开关。一旦发现事情不妙，开启降级就可以了。具体做法是，页面先请求开关接口，若降级，则不安装并且**注销**所有 Service Worker。
```javascript
if (支持SW) {
  fetch(开关接口)
  .then(() => {
    if (降级) {
      // 注销所有已安装的 SW
    } else {
      // 注册 SW
    }
  })
}
```
这里有几点要注意的：
* 降级不是简单的不安装，而是要注销掉。原因是降级前可能已经有用户访问过网站，导致 Service Worker 被安装，不注销的话降级开关对这部分用户是不起作用的。
* 降级开关不能被缓存，需要具备即时性。服务端和 Service Worker 都不该缓存该接口。
* 出现问题并降级后，可能影响问题的排查，因此可以考虑加入对用户隐蔽的 debug 模式（如 url 传入特定字段），debug 模式中忽略降级接口。


## 接入错误监控
由于 Service Worker 运行在 worker 线程里，所以抛出的错误页面是捕捉不到的，因此需要在 Service Worker 里引入错误监控方案。
```javascript
self.addEventListener('error', event => {
  // 上报错误信息
  // 常用的属性：
  // event.message
  // event.filename
  // event.lineno
  // event.colno
  // event.error.stack
})
self.addEventListener('unhandledrejection', event => {
  // 上报错误信息
  // 常用的属性：
  // event.reason
})
```
* Service Worker 大部分 API 都是 promise-based 的，promise 里未处理的错误触发的不是 error 事件，而是 unhandledrejection 事件。
* 这两个事件都只能在 worker 线程的 initial 生命周期里注册。（否则会失败，控制台可看到警告）

## 数据统计
每一个产品都需要数据统计，目的是为了帮助我们更好的理解用户，为业务增长提供数据支撑。同时，其曲线抖动也可以辅助错误监控为生产环境提供监控保障。当然，数据也可以协助运营提供更加好的产品运营解决方案。
## 开发单页面 PWA 应用
前面的准备工作做完后，就可以开始专心写代码了。单页面架构的应用，你只需要：
* 用几个 Service Worker 的库，比如：[sw-precache-webpack-plugin](https://github.com/goldhand/sw-precache-webpack-plugin)
* 找个 manifest.json 抄一下，比如[饿了么 M 站]()的 [manitest.json](https://h5.ele.me/manifest.json)
* 使用 lighthouse 跑一下页面，按照提示改进
* 对比谷歌的 PWA [Checklist ](https://developers.google.com/web/progressive-web-apps/checklist)，按照提示改进
* 国内各大浏览器 Debug 测试：微信、QQ 浏览器、UC 浏览器、百度浏览器、360 浏览器、猎豹浏览器
* 在 10 台安卓机上 Debug 以下系统自带的浏览器

以上基本就 OK 了。
## 开发多页面 PWA 应用 
多页应用会面临更多的问题，比如多页面切换成本高，即使对所有资源都进行了缓存，消除了网络延时，但浏览器销毁页面、解析 HTML、执行 JS、渲染新页面等一系列动作的耗时仍然很高，且几乎无法避免。所以多页应用页面渲染流程的优化，尽可能提高首屏渲染速度是首先要做的事情。
## 用 App Shell 提高首屏渲染速度
提高首屏渲染速度的一个主流方法是使用 [App Shell](https://lark.alipay.com/fgt-mobile/be9mcc/epod4g/edit)。那怎样优雅地写一个 App Shell 呢？既然要求在 JS 加载之前渲染，那是不是意味着只能动手写 DOM？不是的，Vue 2 引入了服务端 Server Side Rendering，简称 SSR。它能够在 Node.js 里渲染 vue 组件并输出为 HTML 片段。因此我们可以在构建阶段调用 Vue SSR 进行 App Shell 的渲染，这也就是所谓的 prerendering。具体的做法可以参考[ vue-server-renderer](https://www.npmjs.com/package/vue-server-renderer) 和 [vue-hackernews](https://github.com/vuejs/vue-hackernews-2.0)。
然而，饿了么 M 站在实践中发现 App Shell 的渲染比预计的要慢：它总是在同步的 JS 解析完成之后才渲染。不过这里有一个简单而行之有效的方法：把耗时的操作推迟到 Event Loop 的任务队列中，等待主调用栈清空后才执行。
```javascript
setTimeout(() => {
  // 把初始化渲染放到 setTimeout 里
  new Vue()
}, 0)
```
虽然只是几行代码的 hack ，但是对 App Shell 的渲染提升是极大的。
![image.jpeg | center | 600x348](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/jpeg/257f24ab-aaa8-44af-ae11-5fa9c31e6aca.jpeg "")
可以看到，加入 App Shell 并且优化后，在主流手机设备上，首屏 App Shell 的渲染时间在 500ms 以下，再加上 SW 对 HTML 的缓存，页面的切换体验可以比较贴近单页应用了。
## 一些踩坑经验
下面是饿了么 M 站在 PWA 改造过程中遇到的坑以及相应的解决方案：
* Android WebView 中 UserAgent 不正确，cookies 丢失
  > 在我们实验性地上线 PWA 后，大数据的同事向我们反馈，他们的统计数据中有有一部分「不正常的 UA」涌入，根据来源分析，这部分 UA 应该是「饿了么 APP」的自定义 UA ，而统计到的数据却为安卓系统默认的 WebView UA。
  > 同一时间，我们还在服务监控中，观察到了某些接口的 401 状态异常上涨。而 401 状态意味着用户认证失败，据此我们推断是 SW 导致 cookies 丢失。
  > 后来我们及时降级 PWA，并与谷歌合作排查，最终确定了 bug 的来源，且将 bug 提交给了 Chrome 团队： [698175 - User agent string not set correctly when Service Worker makes a fetch request - chromium - Monorail]()
  > 在 WebView 修复之前，你可以通过避免在 SW 里代理需要 UA 和 cookies 的请求（通常是API请求）来避开这个 bug。

 
* X5 内核部分请求发送 q-sid 头
  > 在开启 SW 后，微信和 QQ 浏览器都出现了白屏现象。我们利用调试工具观察到部分资源的请求多了一个 q-sid essay-header，这导致浏览器向 CDN 服务器发送 OPTIONS 请求并且遭到拒绝，所以导致页面无法打开。
  > 我们向 X5 内核的团队反馈了这个问题，并且很快得到了技术支持：X5 内核将在新版(4311)中修复这个问题，在此之前，我们可以在服务端设置允许 q-sid 的自定义头部来避开这个问题。

 
* UC 浏览器中 301 跳转问题
  > 同样，我们的页面在 UC 浏览器中也出现了白屏现象，但是 bug 的原因不同：我们发现 SW 抓取的资源中，带 301 跳转的资源请求总是失败的。在向 UC 团队反馈后，我们得到了 bug 的确认，这是内核对 fetch API 的实现基于早期不完善的规范导致的，UC 团队将积极推进内核版本的升级和 bug 的修复。在修复之前，可以采用临时的解决方案：服务端避免 301 跳转，或者 SW 中对存在 301 跳转情况的资源做特殊处理。

 
* 其他细节：
  > 低版本 chromium 不支持 cache.addAll，可以考虑引入带有 polyfill 的库；
  > UC 浏览器不支持 cache.add ，请用 cache.put 代替；
  > 部分低版本微信浏览器中，UA 是 Chrome 30+ 但存在 navigator.serviceWorker，因此不要依赖 [isserviceworkerready](https://jakearchibald.github.io/isserviceworkerready/) 用版本检测代替功能检测；

##参考文章
[PWA 在饿了么的实践经验](http://chuansong.me/n/1676119852913)

## 写在最后
本文会不定期更新，欢迎关注！



