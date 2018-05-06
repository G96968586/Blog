---
title: PWA Cache API 介绍
date: 2017-11-15 17:28:14
categories: PWA
tags: PWA
---
本文重点介绍 Cache 相关技术，不对 Cache 的背景做过多的介绍。希望通过该文能够让读者对 Cache 技术有更进一步的了解。  
CacheStorage 同 App Cache、IndexedDB、LocalStorage 等一样，也是一种数据存储机制，但它能够提供精细的存储控制能力，常与 Fetch API 结合，让页端具备了完全操控请求，响应，缓存的能力，这正是页端一直非常缺乏的能力。在 PWA 中结合 Service Workers ，能够给应用带来更好的离线体验。
<!-- more -->
## API 介绍
CacheStorage 管理一系列 [Cache](https://developer.mozilla.org/en-US/docs/Web/API/Cache) 对象，它提供了多个 JS 方法用于操作 Cache 对象。Cache 跟 Worker 一样，也是暴露在 window 作用域下。下面我们开始介绍 CacheStorage、Cache 的 API 使用。
### CacheStorage
* [CacheStorage.open()](https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage/open) 用于获取一个 Cache 对象实例，结果通过一个 Promise 返回。  

  基本用法：

  ```javascript
  // "caches" is a global read-only variable, which is an instance of CacheStorage
  caches.open(cacheName).then(function(cache) {
    // Do something with your cache
  });
  ```
  Examples：
  ```javascript
  var response;
  // 先从缓存中取
  var cachedResponse = caches.match(event.request).catch(function() {
    // 取不到缓存再去发起网络请求
    return fetch(event.request);
  }).then(function(r) {
    response = r;
    // 成功之后再把数据缓存起来
    caches.open('v1').then(function(cache) {
      cache.put(event.request, response);
    });  
    return response.clone();
  }).catch(function() {
    return caches.match('/sw-test/gallery/myLittleVader.jpg');
  });
  ```
* [CacheStorage.match()](https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage/match) 用于检查 CacheStorage 中是否存在以 Request 为 Key 的 Cache 对象，结果通过一个 Promise 返回。  
  基本用法：
  ```javascript
  caches.match(request, options).then(function(response) {
    // Do something with the response
  });
  ```
  Examples:
  ```javascript
  caches.match(event.request).then(function(response) {
    return response || fetch(event.request).then(function(r) {
      caches.open('v1').then(function(cache) {
        cache.put(event.request, r);
      });
      return r.clone();
    });
  }).catch(function() {
    return caches.match('/sw-test/gallery/myLittleVader.jpg');
  });
  ```
 
* [CacheStorage.keys()](https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage/keys) 用于返回 CacheStorage 中所有 Cache 对象的 Key 列表，结果通过一个 Promise 返回。  
  基本用法：
  ```javascript
  caches.keys().then(function(keyList) {
    //do something with your keyList
  });
  ```
  Examples：
  ```javascript
  this.addEventListener('activate', function(event) {
    var cacheWhitelist = ['v2'];

    event.waitUntil(
      caches.keys().then(function(keyList) {
        return Promise.all(keyList.map(function(key) {
          if (cacheWhitelist.indexOf(key) === -1) {
            return caches.delete(key);
          }
        });
      })
    );
  });
  ```
* [CacheStorage.has()](https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage/has) 用于检查是否存在指定名称的 Cache 对象，结果通过一个 Promise 返回。  
  基本用法：
  ```javascript
  caches.has(cacheName).then(function(boolean) {
    // true: your cache exists!
  });
  ```
  Examples：
  ```javascript
  caches.has('v1').then(function(hasCache) {
    if (!hasCache) {
      someCacheSetupfunction();
    } else {
      caches.open('v1').then(function(cache) {
        return cache.addAll(myAssets);
      });
    }
  }).catch(function() {
    // Handle exception here.
  });
  ```
* [CacheStorage.delete()](https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage/delete) 用于删除指定名称的 Cache 对象，结果通过一个 Promise 返回。  
  基本用法：
  ```javascript
  caches.delete(cacheName).then(function(boolean) {
    // your cache is now deleted
  });
  ```
  Examples：
  ```javascript
  this.addEventListener('activate', function(event) {
    var cacheWhitelist = ['v2'];

    event.waitUntil(
      caches.keys().then(function(keyList) {
        return Promise.all(keyList.map(function(key) {
          if (cacheWhitelist.indexOf(key) === -1) {
            return caches.delete(key);
          }
        }));
      })
    );
  });

  ```


### Cache
Cache 提供了已缓存的 [Request](https://developer.mozilla.org/en-US/docs/Web/API/Request) / [Response](https://fetch.spec.whatwg.org/#response) 对象体的存储管理机制。CacheStorage.open() 开发者可以使用它来获取 Cache 对象实例，使用该实例的方法去管理已缓存的 Request / Response 对象体。
* [Cache.put()](https://developer.mozilla.org/en-US/docs/Web/API/Cache/put) 用于把 Request / Response 对象体放进指定的 Cache。  
  基本用法：
  ```javascript
  cache.put(request, response).then(function() {
    // request/response pair has been added to the cache
  });
  ```
  Examples：
  ```javascript
  // example 1
  fetch(url).then(function(response) {
    if (!response.ok) {
      throw new TypeError('Bad response status');
    }
    return cache.put(url, response);
  })

  // example 2
  var response;
  var cachedResponse = caches.match(event.request).catch(function() {
    return fetch(event.request);
  }).then(function(r) {
    response = r;
    caches.open('v1').then(function(cache) {
      cache.put(event.request, response);
    });  
    return response.clone();
  }).catch(function() {
    return caches.match('/sw-test/gallery/myLittleVader.jpg');
  });
  ```
 
* [Cache.add()](https://developer.mozilla.org/en-US/docs/Web/API/Cache/add) 用于获取一个 Request 的 Response，并将 Request / Response 对象体放进指定的Cache。等价于 fetch(request) + cache.put(request, response)。  
  基本用法：
  ```javascript
  cache.add(request).then(function() {
    // request has been added to the cache
  });
  // 等价于下面
  fetch(url).then(function(response) {
    if (!response.ok) {
      throw new TypeError('bad response status');
    }
    return cache.put(url, response);
  })
  ```
  Examples：
  ```javascript
  this.addEventListener('install', function(event) {
    event.waitUntil(
      caches.open('v1').then(function(cache) {
        return cache.add('/sw-test/index.html');
      })
    );
  });
  ```
 
* [Cache.addAll()](https://developer.mozilla.org/en-US/docs/Web/API/Cache/addAll) 用于获取一组 Request 的 Response，并将该组 Request / Response 对象体放进指定的Cache。
 
  基本用法：
 
  ```javascript
  cache.addAll(requests[]).then(function() {
    // requests have been added to the cache
  });
  ```
 
  Examples：
 
  ```javascript
  this.addEventListener('install', function(event) {
    event.waitUntil(
      caches.open('v1').then(function(cache) {
        return cache.addAll([
          '/sw-test/',
          '/sw-test/index.html',
          '/sw-test/style.css',
          '/sw-test/app.js',
          '/sw-test/image-list.js',
          '/sw-test/star-wars-logo.jpg',
          '/sw-test/gallery/',
          '/sw-test/gallery/bountyHunters.jpg',
          '/sw-test/gallery/myLittleVader.jpg',
          '/sw-test/gallery/snowTroopers.jpg'
        ]);
      })
    );
  });
  ```
 
* [Cache.match()](https://developer.mozilla.org/en-US/docs/Web/API/Cache/match) 用于查找是否存在以 Request 为 Key 的 Cache 对象。
 
  基本用法：
  ```javascript
  cache.match(request, {options}).then(function(response) {
    // Do something with the response
  });
  ```
  Examples：
  ```javascript
  self.addEventListener('fetch', function(event) {
    // We only want to call event.respondWith() if this is a GET request for an HTML document.
    if (event.request.method === 'GET' &&
        event.request.headers.get('accept').indexOf('text/html') !== -1) {
      console.log('Handling fetch event for', event.request.url);
      event.respondWith(
        fetch(event.request).catch(function(e) {
          console.error('Fetch failed; returning offline page instead.', e);
          return caches.open(OFFLINE_CACHE).then(function(cache) {
            return cache.match(OFFLINE_URL);
          });
        })
      );
    }
  });
  ```
 
* [Cache.matchAll()](https://developer.mozilla.org/en-US/docs/Web/API/Cache/matchAll) 用于查找是否存在一组以 Request 为Key的 Cache 对象组。
 
  基本用法：
  ```javascript
  cache.matchAll(request,{options}).then(function(response) {
    //do something with the response array
  });
  ```
  Examples：
  ```javascript
  caches.open('v1').then(function(cache) {
    cache.matchAll('/images/').then(function(response) {
      response.forEach(function(element, index, array) {
        cache.delete(element);
      });
    });
  })
  ```
 
* [Cache.delete()](https://developer.mozilla.org/en-US/docs/Web/API/Cache/delete) 用于删除以 Request 为 Key 的 Cache Entry。注意，Cache 不会过期，只能显式[删除](https://developer.mozilla.org/en-US/docs/Web/API/Cache/delete) 。
  基本用法：
  ```javascript
  cache.delete(request,{options}).then(function(true) {
    //your cache entry has been deleted
  });
  ```
  Examples：
  ```javascript
  caches.open('v1').then(function(cache) {
    cache.delete('/images/image.png').then(function(response) {
      someUIUpdateFunction();
    });
  })
  ```

## 参考文档
[MDN Cache API](https://developer.mozilla.org/en-US/docs/Web/API/Cache)
[MDN CacheStorage API](https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage)
[PWA系列 - Cache 技术](https://www.atatech.org/articles/74883)
