---
title: PWA 添加 Web Push 通知
date: 2017-11-29 15:38:03
categories: PWA
tags: PWA
---
本文主要介绍如何往 PWA 中添加推送通知功能，如果你有兴趣想了解更多关于 Web Push 技术，可以阅读这篇文章[《PWA系列 - Web Push 技术》]()，看一篇抵过 n 篇 Google 的文档。  
<!-- more -->
OK，下面我们进入主题。同样，你需要先做一些准备工作，可以参考这篇[《搭建你的第一个 PWA》]()文章。然后下载示例代码：  
[download: push-notifications-master.zip]()

## 注册 Service Worker
解压示例代码，在 app 目录下有一个 sw.js 的文件，打开你会发现里面除了一些注释和一行 `use strict;`外什么都没有，后面我们会不断往里面添加代码的，因为这个文件是我们的服务工作线程。  
现在，打开 scripts/main.js，这是示例程序的入口，在文件的末尾添加下面代码，
```javascript
if ('serviceWorker' in navigator && 'PushManager' in window) {
  console.log('Service Worker and Push is supported');

  navigator.serviceWorker.register('sw.js')
  .then(function(swReg) {
    console.log('Service Worker is registered', swReg);

    swRegistration = swReg;
  })
  .catch(function(error) {
    console.error('Service Worker Error', error);
  });
} else {
  console.warn('Push messaging is not supported');
  pushButton.textContent = 'Push Not Supported';
}
```
这是一段注册服务工作线程的代码，但你会发现这段代码跟前面文章所介绍的注册服务工作线程有些不太一样，是的，我们这里同时检查了浏览器是否支持推送消息： ‘PushManager’ in window。  
打开 Web Server for Chrome，选择访问目录为 app，  
![屏幕快照 2017-09-17 下午10.23.33.png | center | 644x680](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/e32187ca-e5c1-4071-b1d1-024b0c17621a.png "")
  
在浏览器打开网址 **127.0.0.1:8887 **访问我们的示例应用。如果你前面阅读过 [《调试 Service Workers》](https://lark.alipay.com/fgt-mobile/be9mcc/dt2egy)，并在自己的电脑上做过调试，你也许会访问到这个页面，  
![image | center](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/40be4c5b212b8e6e.png "")
  
这是因为前面我们缓存了一些资源文件，你可以打开开发者工具，切换到 Application 视图 Clear storage 选项，点击 Clear site data，清除缓存再次刷新页面，当你访问到下面这个绿色主题的页面，说明你前面操作成功！  
![屏幕快照 2017-09-17 下午10.29.06.png | center | 2878x1536](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/dc930520-3d40-409a-be0b-c5855057ae78.png "")

### 获取应用服务器密钥
使用示例代码，我们还需要生成一些应用服务器密钥，访问示例代码配套网站：[https://web-push-codelab.appspot.com/](https://web-push-codelab.appspot.com/?hl=zh-cn)，我们可以在这里生成一个公私密钥对。  
![屏幕快照 2017-09-17 下午10.39.05.png | center | 2876x1180](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/7a6cf3b7-be1b-4841-b7c8-ef274ad7862a.png "")
  
点击 refresh keys 按钮，然后将公钥复制到`scripts/main.js`替换`<Your Public Key>`值：
```javascript
const applicationServerPublicKey = '<Your Public Key>';
```
## 初始化状态
你可以发现，目前我们的示例程序页面上的那个按钮不可点击。  
![屏幕快照 2017-09-17 下午11.43.42.png | center | 754x300](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/5d381b34-e1ca-4fc4-a182-4536976f60e3.png "")
  
因为默认情况下最好禁用推送按钮。如果检测到当前浏览器环境支持推送功能，并且当前用户订阅了推送消息，我们再启用此按钮。  
下面我们在 scripts/main.js 里面添加两个函数：
```javascript
// 检查当前用户有没有订阅消息
function initialiseUI() {
  // Set the initial subscription value
  swRegistration.pushManager.getSubscription()
  .then(function(subscription) {
    isSubscribed = !(subscription === null);

    if (isSubscribed) {
      console.log('User IS subscribed.');
    } else {
      console.log('User is NOT subscribed.');
    }

    updateBtn();
  });
}
```

```javascript
// 将启用推送按钮，以及更改用户是否订阅的文本，在 initialiseUI 里调用
function updateBtn() {
  if (isSubscribed) {
    pushButton.textContent = 'Disable Push Messaging';
  } else {
    pushButton.textContent = 'Enable Push Messaging';
  }

  pushButton.disabled = false;
}
```

在注册服务工作线程时调用 initialiseUI() 函数。
```javascript
...
navigator.serviceWorker.register('sw.js')
.then(function(swReg) {
  console.log('Service Worker is registered', swReg);

  swRegistration = swReg;
  // 这里调用
  initialiseUI();
})
...
```

刷新页面，可以看到此时页面上的按钮变成可点击状态了，从 console 控制台上可以看到下面的输出，注意到其中有一句是 `User is NOT subscribed`，下面我们开始来订阅消息。  
![屏幕快照 2017-09-18 上午10.08.52.png | center | 2880x1600](https://private-alipayobjects.alipay.com/alipay-rmsdeploy-image/skylark/png/f51f662b-28d4-4b1b-9c92-ae5e76df6a82.png "")

## 用户订阅
在 initialiseUI() 函数里添加点击事件监听器。
```javascript
function initialiseUI() {
  pushButton.addEventListener('click', function() {
    // 用户点击按钮后，我们先设置按钮处于不可点击状态，防止用户重复订阅消息
    pushButton.disabled = true;
    if (isSubscribed) {
      // TODO: Unsubscribe user
    } else {
      subscribeUser();
    }
  });

  // Set the initial subscription value
  swRegistration.pushManager.getSubscription()
  .then(function(subscription) {
    isSubscribed = !(subscription === null);
    // 注意，这里新增了一行代码
    updateSubscriptionOnServer(subscription);

    if (isSubscribed) {
      console.log('User IS subscribed.');
    } else {
      console.log('User is NOT subscribed.');
    }

    updateBtn();
  });
}
```

在 scripts/main.js 里添加 subscribeUser 函数，
```javascript
function subscribeUser() {
  const applicationServerKey = urlB64ToUint8Array(applicationServerPublicKey);
  swRegistration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: applicationServerKey
  })
  .then(function(subscription) {
    console.log('User is subscribed:', subscription);

    updateSubscriptionOnServer(subscription);

    isSubscribed = true;

    updateBtn();
  })
  .catch(function(err) {
    console.log('Failed to subscribe the user: ', err);
    updateBtn();
  });
}
```
这个函数的作用是，先获取应用服务器的公钥（base64 网址安全编码），然后将其转换为 UInt8Array。转换后，我们调用 swRegistration.pushManager 的 subscribe() 方法，把应用服务器的公钥和 userVisibleOnly: true 传进去。
```javascript
const applicationServerKey = urlB64ToUint8Array(applicationServerPublicKey);
swRegistration.pushManager.subscribe({
  userVisibleOnly: true,
  applicationServerKey: applicationServerKey
})
```
userVisibleOnly 表示在发送推送时显示我们的消息通知。  
调用 subscribe() 方法后会返回一个 promise：

1. 用户已授权显示通知
2. 浏览器已向推送服务发送网络请求，以便获取详细信息来生成 PushSubscription


如果这些步骤成功执行，我们可以在 then 回调里对 subscription 进行解析，如果用户未授权，或者出现其他问题，我们需要在 catch 里做错误处理。

```javascript
swRegistration.pushManager.subscribe({
  userVisibleOnly: true,
  applicationServerKey: applicationServerKey
})
.then(function(subscription) {
  console.log('User is subscribed:', subscription);

  updateSubscriptionOnServer(subscription);

  isSubscribed = true;

  updateBtn();

})
.catch(function(err) {
  console.log('Failed to subscribe the user: ', err);
  updateBtn();
});

```

这样我们就可以收到订阅，并将用户标记为已订阅用户。成功或出错我们都调用 updateBtn 函数来修改按钮文案。下面在 scripts/main.js 里添加 updateSubscriptionOnServer 方法，将订阅发送到后端。

```javascript
function updateSubscriptionOnServer(subscription) {
  // TODO: Send subscription to application server

  const subscriptionJson = document.querySelector('.js-subscription-json');
  const subscriptionDetails =
    document.querySelector('.js-subscription-details');

  if (subscription) {
    subscriptionJson.textContent = JSON.stringify(subscription);
    subscriptionDetails.classList.remove('is-invisible');
  } else {
    subscriptionDetails.classList.add('is-invisible');
  }
}
```

这时候刷新页面，点击订阅按钮，会看到下面的权限提示，

![image | center](https://gw.alicdn.com/tfs/TB1fr7YazuhSKJjSspmXXcQDpXa-2874-1720.png "")


点击允许，可以看到 console 控制台输出了 User is subscribe，同时页面底部出现了订阅信息。

![image | center](https://gw.alicdn.com/tfs/TB1qj89eMMPMeJjy1XdXXasrXXa-2872-1652.png "")


## 处理拒绝的权限

我们还需要处理当用户点击拒绝的情况。因为如果用户拒绝了我们的推送，我们的页面是无法重新显示权限提示的，所以，这里的做法是禁止推送按钮。

在 updateBtn() 里检查 Notification.permission 的值。

```javascript
function updateBtn() {
  // 如果权限为 denied，就无法订阅用户，并且我们无法执行其他操作，因此，停用此按钮是最好的做法
  if (Notification.permission === 'denied') {
    pushButton.textContent = 'Push Messaging Blocked.';
    pushButton.disabled = true;
    updateSubscriptionOnServer(null);
    return;
  }

  if (isSubscribed) {
    pushButton.textContent = 'Disable Push Messaging';
  } else {
    pushButton.textContent = 'Enable Push Messaging';
  }

  pushButton.disabled = false;
}
```

回到浏览器，刷新页面，点击网址栏的圆圈中的 **i**，将通知权限更改为 _Use global default (Ask)_ 。

![image | center](https://gw.alicdn.com/tfs/TB1_dQ1aqagSKJjy0FbXXa.mVXa-2876-1320.png "")


重新加载页面，点击订阅按钮，选择禁止，发现按钮的文案现在改为 Push Messaging Blocked，并且处于不可点击状态。

![image | center](https://gw.alicdn.com/tfs/TB1Y7mgX2NNTKJjSspfXXbXIFXa-2880-1488.png "")


## 处理推送事件

在 sw.js 文件添加下面的推送事件监听器，

```javascript
self.addEventListener('push', function(event) {
  console.log('[Service Worker] Push Received.');
  console.log(`[Service Worker] Push had this data: "${event.data.text()}"`);

  const title = 'Push Codelab';
  const options = {
    body: 'Yay it works.',
    icon: 'images/icon.png',
    badge: 'images/badge.png'
  };

  event.waitUntil(self.registration.showNotification(title, options));
});
```

在我们触发推送消息后，浏览器会收到推送消息，再唤醒相应的服务线程并分配推送事件。我们需要监听此事件，并将通知显示出来。

收到推送消息后，会触发推送事件监听，我们通过在注册时调用 showNotification() 来创建通知并将其显示出来。

```javascript
const title = 'Push Codelab';
const options = {
  body: 'Yay it works.', // 消息正文
  icon: 'images/icon.png', // 图标
  badge: 'images/badge.png' // 标志
};
self.registration.showNotification(title, options);
```

现在我们来测试一下，刷新浏览器，并将通知权限更改为 Use global default (Ask)，选择允许，然后在 Application 视图 Service Workers 选项下点击右边的 Push 按钮，发送模拟通知。

![image | center](https://gw.alicdn.com/tfs/TB1K8Z7aqagSKJjy0FhXXcrbFXa-2880-1488.png "")


会收到类似如下的通知：

![image | center](https://gw.alicdn.com/tfs/TB1HImKeMoQMeJjy0FpXXcTxpXa-716-148.png "")


## 通知点击处理

我们都希望用户收到通知后，去点击它，并作出一些行为，比如，打开一个链接。现在我们来加上这个处理逻辑。

在 sw.js 添加 notificationclick 事件的监听，

```javascript
self.addEventListener('notificationclick', function(event) {
  console.log('[Service Worker] Notification click Received.');

  event.notification.close();

  event.waitUntil(
    clients.openWindow('https://www.taobao.com')
  );
});
```

当用户点击通知时，会调用 notificationclick 事件监听器，打开淘宝首页。

## 发送推送消息

下面我们来发送实际的推送消息了。回到配套网站 [https://web-push-codelab.appspot.com/?hl=zh-cn，刷新密钥](https://web-push-codelab.appspot.com/?hl=zh-cn%EF%BC%8C%E5%88%B7%E6%96%B0%E5%AF%86%E9%92%A5)(因为前面的 key 可能会失效，导致发送消息不成功)，更新 scripts/main.js  的 applicationServerPublicKey，然后回到示例页面，在 Application 视图里切到 Clear storage 选项，点击下边的 Clear site data，刷新页面重新订阅消息。

复制下面这段 Json 字符串，

![image | center](https://gw.alicdn.com/tfs/TB1NWOTeMMPMeJjy1XcXXXpppXa-2880-1658.png "")


然后粘贴到配套网站的 _Subscription to Send To_ 文本区域：

![image | center](https://gw.alicdn.com/tfs/TB1LnGTeMMPMeJjy1XcXXXpppXa-2880-1498.png "")


点击 send push message 按钮，回到我们的示例页面，在控制台可以看到有一句 Push had this data: “This is a test!” 说明我们已经收到了推送消息。

上面的配套网站其实就是使用 [web-push 库](https://github.com/web-push-libs/web-push) 发送消息的节点服务器。我们可以查看 [Github 上的 web-push-libs org](https://github.com/web-push-libs/)，看看有哪些库可以发送推送消息。

## 取消订阅用户

下面介绍如何取消用户的推送消息订阅。我们需要对 PushSubscription 调用 unsubscribe()。

在 scripts/main.js 里将 initialiseUI() 中 pushButton 的点击事件修改为下面代码：

```javascript
pushButton.addEventListener('click', function() {
  pushButton.disabled = true;
  if (isSubscribed) {
    unsubscribeUser();
  } else {
    subscribeUser();
  }
});
```

unsubscribeUser 方法如下：

```javascript
function unsubscribeUser() {
  // 首先，我们通过调用 getSubscription() 获取当前的订阅
  swRegistration.pushManager.getSubscription()
  .then(function(subscription) {
    // 如果 subscription 存在，调用其 unsubscribe 方法
    if (subscription) {
      return subscription.unsubscribe();
    }
  })
  .catch(function(error) {
    console.log('Error unsubscribing', error);
  })
  .then(function() {
    updateSubscriptionOnServer(null);

    console.log('User is unsubscribed.');
    isSubscribed = false;

    updateBtn();
  });
}
```

我们现在来试一试，刷新页面，点击 _Disable Push Messaging_，可以看到控制台输出了：

![image | center](https://gw.alicdn.com/tfs/TB1bLmBeMMPMeJjy1XdXXasrXXa-1878-294.png "")


OK，教程到这里就结束了，如果你想继续深入了解，可以点击下面这两个链接

* Web Fundamentals 上的 [网络推送通知](https://developers.google.com/web/fundamentals/engage-and-retain/push-notifications/?hl=zh-cn) 文档
* [网络推送库](https://github.com/web-push-libs/) - 网络推送库包括 Node.js、PHP、Java 和 Python。


