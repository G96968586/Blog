---
title: 浅析 Composition 事件
date: 2018-05-17 16:59:56
categories: 前端与交互设计
tags: 前端与交互设计
---

今天开会时听同事分享了用 Composition 事件解决输入法的问题，在这里跟大家分享下。

也许你还不清楚什么是 Composition 事件，别着急，在这里，我先跟大家说说我们碰到的输入法问题是什么，这是一个很常见的问题。

<!-- more -->

以微博为例子，我们知道，一条微博最多只能输入 140 个字，这就需要我们实时去计算输入框的字数，输入内容超过长度以后不允许输入，这是一个很常见的功能需求。但实际上，在输入法输入过程中和输入完成时的统计结果有可能是不一致的。

见下面的 Demo ：

![img](https://gw.alicdn.com/tfs/TB1kiwJr7CWBuNjy0FaXXXUlXXa-2878-284.png)

![img](https://gw.alicdn.com/tfs/TB1ofoBr7yWBuNjy0FpXXassXXa-2876-280.png)

另一个例子，比如：输入框输入一二三四五六七八九十。现在已经输入了一二三四五六七八九。如果是实时的去判断并过滤超长内容的话，想要通过输入 shi 来输出十几乎是做不到的，它总是被截断为 sh。这时候我们就可以通过 Composition 事件来解决以上的问题。Composition 的具体介绍可以看比较权威的 [MDN Composition](https://developer.mozilla.org/en-US/docs/Web/API/CompositionEvent)。它主要是用来监听输入法的事件。

composition event在keydown事件之后被触发，触发的是 compositionstart、compositionupdate 还是 compositionend 事件则取决于当时输入法编辑器的状态。你可以通过这个[在线示例](https://dvcs.w3.org/hg/d4e/raw-file/tip/key-event-test.html)来观察键盘的事件和顺序。

Ok, 下面我们可以通过编程来直接解决上面的问题了。

在 [keyboard event](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent) 文档中可以找到 isComposing 事件属性。在 compositionstart 和 compositionend 之间其值为 true。但遗憾的是在目前测试的几个浏览器中，isComposing 的值始终是 undefined。所以需要另觅方法，最容易想到的就是利用 compositionstart 和 compositionend 事件来模拟出 isComposing 这个状态。

```
var isComposing = false;
$input.on('input', function() {
    if(isComposing) return;
    console.log('value change');
}).on('compositionstart compositionend', function(ev) {
    isComposing = ev.type === "compositionstart";
})
```
以上处理在不支持 composition event 的浏览器上也不会出错。

另外，composition 事件有一个 data 属性表示当前的输入值。

```
$input.on('compositionstart compositionupdate compositionend', function(ev) {
    if(ev.type === "compositionstart") {
        // 此时表示进入输入法的开始编辑状态，这个时候ev.data表示输入框中选择的内容，即会被替换掉的内容。
    }else if(ev.type === "compositionupdate") {
        // 此时表示在输入法开始编辑状态之后，新的键入操作。此时 ev.data 为当前输入法编辑器中的内容。
    }else if(ev.type === "compositionend") {
        // 此时表示退出了输入法编辑状态。ev.data 值为即将输出的实际内容。
    }
})
```

Demo 解决方案可参考 [CodePan](https://codepen.io/g96968586/pen/aGQaNE).

React 代码：

```
class InputText extends React.Component {
  state = {
    textLength: 100,
    value: '',
  }
  
  onChange = (e) => {
    const { isComposing } = e.nativeEvent;
    const { value } = e.target;
    const { textLength } = this.state;
    let text = value.replace(/^\s+|\s+$/gmi, '');
    this.setState({ value: text });
    if (!isComposing) {
      if (text.length > 100) {
        text = text.substring(0, 100);
      }
      this.setState({
        textLength: 100 - text.length,
      })  
    } 
  }
  
  onComposition = (e) => {
    if (e.type === 'compositionend') {
      const { value } = e.target;
      let text = value.replace(/^\s+|\s+$/gmi, '');
      if (text.length > 100) {
        text = text.substring(0, 100);
      }
      this.setState({
        textLength: 100 - text.length,
        value: text,
      });
    }
  }
  
  render() {
    return (
      <div>
        <div className="right">还可以输入 <strong>{this.state.textLength}</strong> 个字  </div>
        <TextArea
          placeholder="字数限制100"
          autosize={{ minRows: 2, maxRows: 6 }}
          onChange={this.onChange}
          onCompositionStart={this.onComposition}
          onCompositionUpdate={this.onComposition}
          onCompositionEnd={this.onComposition}
          value={this.state.value}
        />
      </div>
    );
  }
}
```

效果图见下面：

![img](https://gw.alicdn.com/tfs/TB16NiLsntYBeNjy1XdXXXXyVXa-2878-284.png)

![img](https://gw.alicdn.com/tfs/TB14NiLsntYBeNjy1XdXXXXyVXa-2878-282.png)

注意!!! 在移动端（ios7、android4.3）对于输入法几乎都不响应 keyup 事件。而开启计时器来做判断的话，在 IOS6 以下会有些莫名的问题。所以移动端慎用。