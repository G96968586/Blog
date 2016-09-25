---
title: 样式辅助文件 flexbox.scss
date: 2016-09-25 23:50:21
categories: CSS
tags: [样式,代码]
---
```scss
.FBH,
.FBV {
  display: -webkit-box;
  display: -webkit-flex;
  display: flex;
}
.FBV {
  -webkit-box-orient: vertical;
  -webkit-box-direction: normal;
  -webkit-flex-direction: column;
  flex-direction: column;
}
.FBAS {
  -webkit-box-align: start;
  -webkit-align-items: flex-start;
  align-items: flex-start;
}
.FBAC {
  -webkit-box-align: center;
  -webkit-align-items: center;
  align-items: center;
}
.FBAE {
  -webkit-box-align: end;
  -webkit-align-items: flex-end;
  align-items: flex-end;
}
.FBJS {
  -webkit-box-pack: start;
  -webkit-justify-content: flex-start;
  justify-content: flex-start;
}
.FBJC {
  -webkit-box-pack: center;
  -webkit-justify-content: center;
  justify-content: center;
}
.FBJE {
  -webkit-box-pack: end;
  -webkit-justify-content: flex-end;
  justify-content: flex-end;
}
.FBJ {
  -webkit-box-pack: justify;
  -webkit-justify-content: space-between;
  justify-content: space-between;
}
.FB1, .FB2, .FB3{
  display: block;
}
.FBH > .FB1,
.FBH > .FB2,
.FBH > .FB3 {
  width: 0;
}
.FB1 {
  -webkit-box-flex: 1;
  -webkit-flex: 1;
  flex: 1;
}
.FB2 {
  -webkit-box-flex: 2;
  -webkit-flex: 2;
  flex: 2;
}
.FB3 {
  -webkit-box-flex: 3;
  -webkit-flex: 3;
  flex: 3;
}
```
