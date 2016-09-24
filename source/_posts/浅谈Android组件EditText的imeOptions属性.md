---
title: 浅谈 Android 组件 EditText 的 imeOptions 属性
date: 2016-09-17 22:09:34
categories: Android
tags: 转载
---
我们有时为了提升app的用户体验，想在用户注册或者登录时，输入完最后一个输入框后，通过点击右下角的”开始“/”完成“可以直接注册或者登录，见图：
![](http://img.blog.csdn.net/20140830173833281?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvZzk2OTY4NTg2/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

看了api，EditText的imeOptions这个属性可以实现这一功能，于是把它加进去，这是我的布局文件，

```xml
<?xml version="1.0" encoding="utf-8"?>  
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"  
    android:layout_width="match_parent"  
    android:layout_height="match_parent"  
    android:orientation="vertical" >  

<EditText   
    android:id="@+id/edit"  
    android:layout_width="match_parent"  
    android:layout_height="wrap_content"  
    android:imeOptions="actionNext"     
    />  

<EditText   
    android:id="@+id/edit2"  
    android:layout_width="match_parent"  
    android:layout_height="wrap_content"  
    android:imeOptions="actionGo"  
    />  
</LinearLayout>  
```

imeOptions有这么几个选项，

（1）actionUnspecified未指定，对应常量EditorInfo.IME_ACTION_UNSPECIFIED

（2）actionNone 没有动作,对应常量EditorInfo.IME_ACTION_NONE

（3）actionGo去往，对应常量EditorInfo.IME_ACTION_GO

（4）actionSearch 搜索，对应常量EditorInfo.IME_ACTION_SEARCH

（5）actionSend 发送，对应常量EditorInfo.IME_ACTION_SEND

（6）actionNext 下一个，对应常量EditorInfo.IME_ACTION_NEXT

（7）actionDone 完成，对应常量EditorInfo.IME_ACTION_DONE

可是在我跑起程序的时候并没有发现想要的效果，如图：
![](http://img.blog.csdn.net/20140830174816366?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvZzk2OTY4NTg2/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

原来想要使用imeOptions这个属性，还必须要设置这个属性，android:inputType="text"，添加进去布局文件就可以看到第一张图的效果了。


在Activity里怎么去监听呢？当我们点击开始时要进行登录或者注册？可以实现这个监听器，看代码：

```java

import android.app.Activity;  
import android.os.Bundle;  
import android.view.KeyEvent;  
import android.view.inputmethod.EditorInfo;  
import android.widget.EditText;  
import android.widget.TextView;  
import android.widget.Toast;  

public class EditTextDemo extends Activity {  
    private EditText test, test2;  

    @Override  
protected void onCreate(Bundle savedInstanceState) {  
    // TODO Auto-generated method stub  
    super.onCreate(savedInstanceState);  
    setContentView(R.layout.t2);  
    test=(EditText) findViewById(R.id.edit);  
    test2=(EditText) findViewById(R.id.edit2);  
    //test.setImeOptions(EditorInfo.IME_ACTION_NEXT);//代码里可以这样添加这个属性  
    test2.setOnEditorActionListener(new TextView.OnEditorActionListener() {  

        @Override  
        public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {  
            if (actionId == EditorInfo.IME_ACTION_GO) {  
                Toast.makeText(T2.this, "你点了完成", Toast.LENGTH_SHORT).show();  
            }  
            return false;  
        }  
    });  
}  
```

![](http://img.blog.csdn.net/20140830175025312?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvZzk2OTY4NTg2/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

![](http://img.blog.csdn.net/20140830173833281?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvZzk2OTY4NTg2/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
