---
title: ADB 常用命令
date: 2016-10-23 22:30:30
categories: Android
tags:

---

### ADB 常用命令总结：

*    显示系统全部的 Android 平台

     `android list targets`

     output:

     ```shell
     ➜  android list targets
     Available Android targets:
     ----------
     id: 1 or "android-21"
          Name: Android 5.0.1
          Type: Platform
          API level: 21
          Revision: 2
          Skins: HVGA, QVGA, WQVGA400, WQVGA432, WSVGA, WVGA800 (default), WVGA854, WXGA720, WXGA800, WXGA800-7in
      Tag/ABIs : no ABIs.
     ----------
     id: 2 or "android-22"
          Name: Android 5.1.1
          Type: Platform
          API level: 22
          Revision: 2
          Skins: HVGA, QVGA, WQVGA400, WQVGA432, WSVGA, WVGA800 (default), WVGA854, WXGA720, WXGA800, WXGA800-7in, AndroidWearRound, AndroidWearRound400x400, AndroidWearRoundChin320x290, AndroidWearRoundChin360x325, AndroidWearRoundChin360x330, AndroidWearSquare, AndroidWearSquare320x320, AndroidWearRound, AndroidWearRound400x400, AndroidWearRoundChin320x290, AndroidWearRoundChin360x325, AndroidWearRoundChin360x330, AndroidWearSquare, AndroidWearSquare320x320
      Tag/ABIs : android-tv/armeabi-v7a, android-tv/x86, android-wear/armeabi-v7a, android-wear/x86, default/armeabi-v7a, default/x86, default/x86_64
     ----------
     id: 3 or "android-23"
          Name: Android 6.0
          Type: Platform
          API level: 23
          Revision: 3
          Skins: HVGA, QVGA, WQVGA400, WQVGA432, WSVGA, WVGA800 (default), WVGA854, WXGA720, WXGA800, WXGA800-7in
      Tag/ABIs : no ABIs.
     ----------
     id: 4 or "android-N"
          Name: Android N (Preview)
          Type: Platform
          API level: N
          Revision: 3
          Skins: HVGA, QVGA, WQVGA400, WQVGA432, WSVGA, WVGA800 (default), WVGA854, WXGA720, WXGA800, WXGA800-7in
      Tag/ABIs : no ABIs.
     ----------
     id: 5 or "android-24"
          Name: Android N
          Type: Platform
          API level: 24
          Revision: 1
          Skins: HVGA, QVGA, WQVGA400, WQVGA432, WSVGA, WVGA800 (default), WVGA854, WXGA720, WXGA800, WXGA800-7in
      Tag/ABIs : android-tv/x86, default/arm64-v8a, default/armeabi-v7a, default/x86, default/x86_64
     ----------
     id: 6 or "Google Inc.:Google APIs:22"
          Name: Google APIs
          Type: Add-On
          Vendor: Google Inc.
          Revision: 1
          Description: Android + Google APIs
          Based on Android 5.1.1 (API level 22)
          Libraries:
     * com.android.future.usb.accessory (usb.jar)
         API for USB Accessories
     * com.google.android.media.effects (effects.jar)
         Collection of video effects
     * com.google.android.maps (maps.jar)
         API for Google Maps   
         Skins: HVGA, QVGA, WQVGA400, WQVGA432, WSVGA, WVGA800 (default), WVGA854, WXGA720, WXGA800, WXGA800-7in, AndroidWearRound, AndroidWearRound400x400, AndroidWearRoundChin320x290, AndroidWearRoundChin360x325, AndroidWearRoundChin360x330, AndroidWearSquare, AndroidWearSquare320x320, AndroidWearRound, AndroidWearRound400x400, AndroidWearRoundChin320x290, AndroidWearRoundChin360x325, AndroidWearRoundChin360x330, AndroidWearSquare, AndroidWearSquare320x320
         Tag/ABIs : google_apis/x86  
     ...
     ```

*    安装应用

        `adb install xxx.apk`

        output:

     ```shell
     ➜  adb install newjob.apk 
     [100%] /data/local/tmp/newjob.apk
     pkg: /data/local/tmp/newjob.apk
     Success
     ```

        如果手机已经存在 newjob 应用，则会报

     ```shell
     ➜  adb install newjob.apk 
     [100%] /data/local/tmp/newjob.apk
     pkg: /data/local/tmp/newjob.apk
     Failure [INSTALL_FAILED_ALREADY_EXISTS]
     ```

     这时候，加一个 -r 参数，代表重新安装，就不会报上面的错误了，

     ```shell
     ➜  adb install -r newjob.apk
     [100%] /data/local/tmp/newjob.apk
     pkg: /data/local/tmp/newjob.apk
     Success
     ```


*    Push 将文件写入手机存储系统

     `adb push <local> <remote>`

     只要拥有相应的权限，就可以把任何文件写入到手机的任何目录下。比如，前面我们通过 install 将一个 App 安装到手机上，这里，我们也可以把 Apk Push 到 Sdcard 再手动点击安装。

     `adb push ~/Desktop/newjob.apk /sdcard/`

     同理，既然可以将文件写入手机，也可以将手机里的文件取出来。

*    Pull 获取手机中的文件

      `adb pull <remote> <local>`       

     eg: 


     ```shell
     ➜  adb pull /sdcard/ newjob.apk
     ```

*    查看 Log 日志

      `adb shell   `  进入 adb 命令行窗口，

      `logcat | grep "XX"`

      eg:


     ```shell
     ➜  adb shell
     shell@virgo:/ $ logcat | grep "NJ"
     10-21 11:18:34.767  2572  4823 I ActivityManager: START u0 {cmp=com.taobao.newjob.debug/com.taobao.newjob.module.main.NJMainActivity} from uid 10151 on display 0
     10-21 14:12:03.610  2572  5054 I ActivityManager: START u0 {cmp=com.taobao.newjob/.module.main.NJMainActivity} from uid 10154 on display 0
     10-21 15:49:33.229  2572  2659 I ActivityManager:   Force finishing activity ActivityRecord{c06ee19 u0 com.taobao.newjob.debug/com.taobao.newjob.module.main.NJMainActivity t673}
     10-21 15:49:38.330  2572  5128 I ActivityManager: START u0 {cmp=com.taobao.newjob.debug/com.taobao.newjob.module.main.NJMainActivity} from uid 10151 on display 0
     10-21 15:55:29.015  2572  5054 I ActivityManager: START u0 {cmp=com.taobao.newjob.debug/com.taobao.newjob.module.main.NJMainActivity} from uid 10151 on display 0
     10-21 16:25:23.751  2572  4785 I ActivityManager: START u0 {cmp=com.taobao.newjob.debug/com.taobao.newjob.module.main.NJMainActivity} from uid 10151 on display 0
     ```

*    卸载应用

       `adb uninstall 包名`


     ```shell
     ➜  adb uninstall com.taobao.newjob
     Success
     ```

*    查看系统盘符

     `adb shell df`


     ```shell
     ➜  adb shell df
     Filesystem               Size     Used     Free   Blksize
     /dev                   800.0M   116.0K   799.9M   4096
     /var                     1.4G     0.0K     1.4G   4096
     /sys/fs/cgroup           1.4G     0.0K     1.4G   4096
     /sys/fs/cgroup/memory: Permission denied
     /mnt                     1.4G     0.0K     1.4G   4096
     /sys/fs/cgroup           1.4G     0.0K     1.4G   4096
     /sys/fs/cgroup/memory: Permission denied
     /sys/fs/cgroup/freezer: Permission denied
     /system                  1.5G     1.3G   223.6M   4096
     /data                   12.2G     4.7G     7.5G   4096
     /cache                 377.8M     6.3M   371.5M   4096
     /persist                15.7M     4.1M    11.6M   4096
     /firmware               64.0M    53.1M    10.9M   16384
     /storage                 1.4G     0.0K     1.4G   4096
     /mnt/runtime/default/emulated: Permission denied
     /storage/emulated       12.2G     4.7G     7.5G   4096
     /mnt/runtime/read/emulated: Permission denied
     /mnt/runtime/write/emulated: Permission denied
     ```

*    查看所有已安装的应用

      `adb shell pm list packages -f`


     ```shell
     ➜ adb shell pm list packages -f
     package:/data/app/com.homelink.android-1/base.apk=com.homelink.android
     package:/system/priv-app/TelephonyProvider/TelephonyProvider.apk=com.android.providers.telephony
     package:/system/app/PowerKeeper/PowerKeeper.apk=com.miui.powerkeeper
     package:/data/app/io.appium.settings-1/base.apk=io.appium.settings
     package:/system/priv-app/CalendarProvider/CalendarProvider.apk=com.android.providers.calendar
     package:/system/priv-app/MediaProvider/MediaProvider.apk=com.android.providers.media
     package:/system/app/MiLinkService/MiLinkService.apk=com.milink.service
     package:/system/priv-app/SpacesTrustAgent/SpacesTrustAgent.apk=com.securespaces.android.trustagent
     package:/system/app/XiaomiAccount/XiaomiAccount.apk=com.xiaomi.account
     package:/system/app/shutdownlistener/shutdownlistener.apk=com.qualcomm.shutdownlistner
     package:/system/priv-app/WallpaperCropper/WallpaperCropper.apk=com.android.wallpapercropper
     package:/system/priv-app/CNEService/CNEService.apk=com.quicinc.cne.CNEService
     package:/system/app/MiLivetalk/MiLivetalk.apk=com.miui.milivetalk
     package:/system/app/Updater/Updater.apk=com.android.updater
     package:/system/app/DocumentsUI/DocumentsUI.apk=com.android.documentsui
     package:/system/app/Galaxy4/Galaxy4.apk=com.android.galaxy4
     package:/system/priv-app/ExternalStorageProvider/ExternalStorageProvider.apk=com.android.externalstorage
     package:/system/priv-app/MiGameCenterSDKService/MiGameCenterSDKService.apk=com.xiaomi.gamecenter.sdk.service
     ...
     ```

*    模拟输入

      `adb shell input keyevent code`


     ```shell
     ➜  adb shell input keyevent 3 (home)
     ➜  adb shell input keyevent 4 (back)
     ➜  adb shell input keyevent 19 (up)
     ➜  adb shell input keyevent 20 (down)
     ➜  adb shell input keyevent 21 (left)
     ➜  adb shell input keyevent 22 (right)
     ➜  adb shell input keyevent 82 (menu)
     ...
     (其他请参考 API 文档)
     ```

*    查看 Activity 运行状态

      `adb shell dumpsys activity activities`


     ```shell
     ➜  adb shell dumpsys activity activities | grep "newjob"
     * TaskRecord{6a88af6 #752 A=com.taobao.newjob U=0 sz=1}
     userId=0 effectiveUid=u0a154 mCallingUid=u0a154 mCallingPackage=com.taobao.newjob
     affinity=com.taobao.newjob
     intent={act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=com.taobao.newjob/.module.launch.LaunchActivity}
     realActivity=com.taobao.newjob/.module.launch.LaunchActivity
     Activities=[ActivityRecord{b3c21c2 u0 com.taobao.newjob/.module.main.NJMainActivity t752}]
     * Hist #0: ActivityRecord{b3c21c2 u0 com.taobao.newjob/.module.main.NJMainActivity t752}
     packageName=com.taobao.newjob processName=com.taobao.newjob
     launchedFromUid=10154 launchedFromPackage=com.taobao.newjob userId=0
     app=ProcessRecord{4340cfa 15047:com.taobao.newjob/u0a154}
     Intent { flg=0x10000000 cmp=com.taobao.newjob/.module.main.NJMainActivity }
     frontOfTask=true task=TaskRecord{6a88af6 #752 A=com.taobao.newjob U=0 sz=1}
     taskAffinity=com.taobao.newjob
     realActivity=com.taobao.newjob/.module.main.NJMainActivity
     baseDir=/data/app/com.taobao.newjob-1/base.apk
     dataDir=/data/user/0/com.taobao.newjob
     TaskRecord{6a88af6 #752 A=com.taobao.newjob U=0 sz=1}
     Run #2: ActivityRecord{b3c21c2 u0 com.taobao.newjob/.module.main.NJMainActivity t752}
     mResumedActivity: ActivityRecord{b3c21c2 u0 com.taobao.newjob/.module.main.NJMainActivity t752}
     mLastPausedActivity: ActivityRecord{28c42b5 u0 com.taobao.newjob/.module.launch.LaunchActivity t752 f}
     mFocusedActivity: ActivityRecord{b3c21c2 u0 com.taobao.newjob/.module.main.NJMainActivity t752}
     ```
* 启动一个 Activity

  `adb shell am start -n 包名/包名+类名`

  ```shell
  ➜  adb shell am start -n com.taobao.newjob/com.taobao.newjob.module.launch.LaunchActivity
  Starting: Intent { cmp=com.taobao.newjob/.module.launch.LaunchActivity }
  ```

* 录制屏幕

  `adb shell screenrecord /路径/xxx/mp4`

* 手机重新启动

  `adb reboot`

* 当电脑上有多个设备 online 时，指定链接到某个设备向其发送命令

  ```shell
  ➜  ~ adb devices (先查看有哪些设备)
  List of devices attached
  192.168.57.101:5555     device
  1d760d8a        device
  ```

  现在我们链接下面的那个设备 1d760d8a，通过`adb -s <serial number> cmd`指定向其发送 shell 命令，

  ```shell
  ➜  ~ adb -s 1d760d8a shell
  shell@virgo:/ $
  ```

  导出一个应用的数据库到本地 Desktop 目录下面，

  ```shell
  ➜  ~ adb -s 192.168.57.101:5555 pull /data/data/com.taobao.newjob.debug/databases/logdb.db ~/Desktop
  [100%] /data/data/com.taobao.newjob.debug/databases/logdb.db
  ```

  运行其它命令同上面。

  ​