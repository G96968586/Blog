---
title: weekly 1008
date: 2016-10-08 23:20:16
categories: WeeklyTask
tags: 每周总结
---
* 最近在做 React 开发时，遇到了这样一个问题，
```JavaScript
class TodoApp extends Component{
    getInitialState(){
         // some thing
    }
}
```
<!-- more -->

getInitialState 不会调用，浏览器输出了下面的信息，
```
Warning: getInitialState was defined on TodoApp, a plain JavaScript class. This is only supported for classes created using React.createClass. Did you mean to define a state property instead?
```
上网查了一下，原来 React 在 ES6 的实现中去掉了 getInitialState 这个 hook 函数，规定 state 在 constructor 中实现，如下：
```JavaScript
Class App extends Component {

constructor(props) {
    super(props);
    this.state = {};
}    
...
}
```
Babel的Blog上还有一种实现方法，即直接使用赋值语句：

```JavaScript
Class App extends React.Component {

constructor(props) {
    super(props);
}

state = {}    
...
}
```
