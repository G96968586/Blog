---
title: 不用 AIDL 实现 IPC 的一个简便方法
date: 2016-08-02 13:07:00
categories: Android
tags: Android
---

- Service 实现一个 Handler 来接受 Client 的每一个 callback。
- 这个 Handler 用来创建 Messenger 对象。
- Messenger 创建一个 IBinder 对象，Service 在 onBind 方法里面把这个对象返回给客户端。
- 客户端使用这个 IBinder 对象来实例化 Messenger (that references the service’s Handler), 然后客户端使用这个 messager 再发送 message 对象给 service。
- Service 在它的 handler 里面接收到每一个 Message。
<!-- more -->
先看一个精简版的例子：

Service代码示例:

```java
public class MessengerService extends Service{
    /** Command to the service to display a message */
    static final int MSG_SAY_HELLO =1;

    /**
     * Handler of incoming messages from clients.
     */
    class IncomingHandler extends Handler{
        @Override
        public void handleMessage(Message msg){
            switch(msg.what){
                case MSG_SAY_HELLO:
                    Toast.makeText(getApplicationContext(),"hello!",Toast.LENGTH_SHORT).show();
                    break;
                default:
                    super.handleMessage(msg);
            }
        }
    }

    /**
     * Target we publish for clients to send messages to IncomingHandler.
     */
    final Messenger mMessenger =new Messenger(newIncomingHandler());

    /**
     * When binding to the service, we return an interface to our messenger
     * for sending messages to the service.
     */
    @Override
    public IBinder onBind(Intent intent){
        Toast.makeText(getApplicationContext(),"binding",Toast.LENGTH_SHORT).show();
        return mMessenger.getBinder();
    }
}

```

Client端代码:

```java
public class ActivityMessenger extends Activity{
    /** Messenger for communicating with the service. */
    Messenger mService =null;

    /** Flag indicating whether we have called bind on the service. */
    boolean mBound;

    /**
     * Class for interacting with the main interface of the service.
     */
    private ServiceConnection mConnection = new ServiceConnection(){
        publicvoid onServiceConnected(ComponentName className,IBinder service){
            // This is called when the connection with the service has been
            // established, giving us the object we can use to
            // interact with the service.  We are communicating with the
            // service using a Messenger, so here we get a client-side
            // representation of that from the raw IBinder object.
            mService = new Messenger(service);
            mBound = true;
        }

        public void onServiceDisconnected(ComponentName className){
            // This is called when the connection with the service has been
            // unexpectedly disconnected -- that is, its process crashed.
            mService = null;
            mBound = false;
        }
    };

    public void sayHello(View v){
        if(!mBound) return;
        // Create and send a message to the service, using a supported 'what' value
        Message msg = Message.obtain(null,MessengerService.MSG_SAY_HELLO,0,0);
        try{
            mService.send(msg);
        }catch(RemoteException e){
            e.printStackTrace();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
    }

    @Override
    protected void onStart(){
        super.onStart();
        // Bind to the service
        bindService(newIntent(this,MessengerService.class), mConnection,
            Context.BIND_AUTO_CREATE);
    }

    @Override
    protected void onStop(){
        super.onStop();
        // Unbind from the service
        if(mBound){
            unbindService(mConnection);
            mBound =false;
        }
    }
}
```

下面演示 Service 接收到 Client 的 Msg 之后，如何再与 Client 进行交互的。

Google Sample Demo：

Service：

```java
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.example.android.apis.app;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.Messenger;
import android.os.RemoteException;
import android.util.Log;
import android.widget.Toast;
import java.util.ArrayList;
// Need the following import to get access to the app resources, since this
// class is in a sub-package.
import com.example.android.apis.R;
import com.example.android.apis.app.RemoteService.Controller;
/**
 * This is an example of implementing an application service that uses the
 * {@link Messenger} class for communicating with clients.  This allows for
 * remote interaction with a service, without needing to define an AIDL
 * interface.
 *
 * <p>Notice the use of the {@link NotificationManager} when interesting things
 * happen in the service.  This is generally how background services should
 * interact with the user, rather than doing something more disruptive such as
 * calling startActivity().
 */
//BEGIN_INCLUDE(service)
public class MessengerService extends Service {
    /** For showing and hiding our notification. */
    NotificationManager mNM;
    /** Keeps track of all current registered clients. */
    ArrayList<Messenger> mClients = new ArrayList<Messenger>();
    /** Holds last value set by a client. */
    int mValue = 0;
    
    /**
     * Command to the service to register a client, receiving callbacks
     * from the service.  The Message's replyTo field must be a Messenger of
     * the client where callbacks should be sent.
     */
    static final int MSG_REGISTER_CLIENT = 1;
    
    /**
     * Command to the service to unregister a client, ot stop receiving callbacks
     * from the service.  The Message's replyTo field must be a Messenger of
     * the client as previously given with MSG_REGISTER_CLIENT.
     */
    static final int MSG_UNREGISTER_CLIENT = 2;
    
    /**
     * Command to service to set a new value.  This can be sent to the
     * service to supply a new value, and will be sent by the service to
     * any registered clients with the new value.
     */
    static final int MSG_SET_VALUE = 3;
    
    /**
     * Handler of incoming messages from clients.
     */
    class IncomingHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MSG_REGISTER_CLIENT:
                    mClients.add(msg.replyTo);
                    break;
                case MSG_UNREGISTER_CLIENT:
                    mClients.remove(msg.replyTo);
                    break;
                case MSG_SET_VALUE:
                    mValue = msg.arg1;
                    for (int i=mClients.size()-1; i>=0; i--) {
                        try {
                            mClients.get(i).send(Message.obtain(null,
                                    MSG_SET_VALUE, mValue, 0));
                        } catch (RemoteException e) {
                            // The client is dead.  Remove it from the list;
                            // we are going through the list from back to front
                            // so this is safe to do inside the loop.
                            mClients.remove(i);
                        }
                    }
                    break;
                default:
                    super.handleMessage(msg);
            }
        }
    }
    
    /**
     * Target we publish for clients to send messages to IncomingHandler.
     */
    final Messenger mMessenger = new Messenger(new IncomingHandler());
    
    @Override
    public void onCreate() {
        mNM = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);
        // Display a notification about us starting.
        showNotification();
    }
    @Override
    public void onDestroy() {
        // Cancel the persistent notification.
        mNM.cancel(R.string.remote_service_started);
        // Tell the user we stopped.
        Toast.makeText(this, R.string.remote_service_stopped, Toast.LENGTH_SHORT).show();
    }
    
    /**
     * When binding to the service, we return an interface to our messenger
     * for sending messages to the service.
     */
    @Override
    public IBinder onBind(Intent intent) {
        return mMessenger.getBinder();
    }
    /**
     * Show a notification while this service is running.
     */
    private void showNotification() {
        // In this sample, we'll use the same text for the ticker and the expanded notification
        CharSequence text = getText(R.string.remote_service_started);
        // The PendingIntent to launch our activity if the user selects this notification
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0,
                new Intent(this, Controller.class), 0);
        // Set the info for the views that show in the notification panel.
        Notification notification = new Notification.Builder(this)
                .setSmallIcon(R.drawable.stat_sample)  // the status icon
                .setTicker(text)  // the status text
                .setWhen(System.currentTimeMillis())  // the time stamp
                .setContentTitle(getText(R.string.local_service_label))  // the label of the entry
                .setContentText(text)  // the contents of the entry
                .setContentIntent(contentIntent)  // The intent to send when the entry is clicked
                .build();
        // Send the notification.
        // We use a string id because it is a unique number.  We use it later to cancel.
        mNM.notify(R.string.remote_service_started, notification);
    }
}
//END_INCLUDE(service)
```

Client：

```java
package io.appium.android.apis.app;

import io.appium.android.apis.R;
import io.appium.android.apis.app.LocalServiceActivities.Binding;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.Messenger;
import android.os.RemoteException;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

public class MessengerServiceActivities {
    /**
     * Example of binding and unbinding to the remote service.
     * This demonstrates the implementation of a service which the client will
     * bind to, interacting with it through an aidl interface.</p>
     * 
     * <p>Note that this is implemented as an inner class only keep the sample
     * all together; typically this code would appear in some separate class.
     */
    public static class Binding extends Activity {

        /** Messenger for communicating with service. */
        Messenger mService = null;
        /** Flag indicating whether we have called bind on the service. */
        boolean mIsBound;
        /** Some text view we are using to show state information. */
        TextView mCallbackText;
        
        /**
         * Handler of incoming messages from service.
         */
        class IncomingHandler extends Handler {
            @Override
            public void handleMessage(Message msg) {
                switch (msg.what) {
                    case MessengerService.MSG_SET_VALUE:
                        mCallbackText.setText("Received from service: " + msg.arg1);
                        break;
                    default:
                        super.handleMessage(msg);
                }
            }
        }
        
        /**
         * Target we publish for clients to send messages to IncomingHandler.
         */
        final Messenger mMessenger = new Messenger(new IncomingHandler());
        
        /**
         * Class for interacting with the main interface of the service.
         */
        private ServiceConnection mConnection = new ServiceConnection() {
            public void onServiceConnected(ComponentName className,
                    IBinder service) {
                // This is called when the connection with the service has been
                // established, giving us the service object we can use to
                // interact with the service.  We are communicating with our
                // service through an IDL interface, so get a client-side
                // representation of that from the raw service object.
                mService = new Messenger(service);
                mCallbackText.setText("Attached.");

                // We want to monitor the service for as long as we are
                // connected to it.
                try {
                    Message msg = Message.obtain(null,
                            MessengerService.MSG_REGISTER_CLIENT);
                    msg.replyTo = mMessenger;
                    mService.send(msg);
                    
                    // Give it some value as an example.
                    msg = Message.obtain(null,
                            MessengerService.MSG_SET_VALUE, this.hashCode(), 0);
                    mService.send(msg);
                } catch (RemoteException e) {
                    // In this case the service has crashed before we could even
                    // do anything with it; we can count on soon being
                    // disconnected (and then reconnected if it can be restarted)
                    // so there is no need to do anything here.
                }
                
                // As part of the sample, tell the user what happened.
                Toast.makeText(Binding.this, R.string.remote_service_connected,
                        Toast.LENGTH_SHORT).show();
            }

            public void onServiceDisconnected(ComponentName className) {
                // This is called when the connection with the service has been
                // unexpectedly disconnected -- that is, its process crashed.
                mService = null;
                mCallbackText.setText("Disconnected.");

                // As part of the sample, tell the user what happened.
                Toast.makeText(Binding.this, R.string.remote_service_disconnected,
                        Toast.LENGTH_SHORT).show();
            }
        };
        
        void doBindService() {
            // Establish a connection with the service.  We use an explicit
            // class name because there is no reason to be able to let other
            // applications replace our component.
            bindService(new Intent(Binding.this, 
                    MessengerService.class), mConnection, Context.BIND_AUTO_CREATE);
            mIsBound = true;
            mCallbackText.setText("Binding.");
        }
        
        void doUnbindService() {
            if (mIsBound) {
                // If we have received the service, and hence registered with
                // it, then now is the time to unregister.
                if (mService != null) {
                    try {
                        Message msg = Message.obtain(null,
                                MessengerService.MSG_UNREGISTER_CLIENT);
                        msg.replyTo = mMessenger;
                        mService.send(msg);
                    } catch (RemoteException e) {
                        // There is nothing special we need to do if the service
                        // has crashed.
                    }
                }
                
                // Detach our existing connection.
                unbindService(mConnection);
                mIsBound = false;
                mCallbackText.setText("Unbinding.");
            }
        }

        
        /**
         * Standard initialization of this activity.  Set up the UI, then wait
         * for the user to poke it before doing anything.
         */
        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);

            setContentView(R.layout.messenger_service_binding);

            // Watch for button clicks.
            Button button = (Button)findViewById(R.id.bind);
            button.setOnClickListener(mBindListener);
            button = (Button)findViewById(R.id.unbind);
            button.setOnClickListener(mUnbindListener);
            
            mCallbackText = (TextView)findViewById(R.id.callback);
            mCallbackText.setText("Not attached.");
        }

        private OnClickListener mBindListener = new OnClickListener() {
            public void onClick(View v) {
                doBindService();
            }
        };

        private OnClickListener mUnbindListener = new OnClickListener() {
            public void onClick(View v) {
                doUnbindService();
            }
        };
    }
}
```



