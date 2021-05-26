[![license](https://img.shields.io/badge/license-BSD_2-brightgreen.svg?style=flat)](https://github.com/mutour/build-opencv-for-android/blob/main/LICENSE)

## 环境

经过验证的版本:  
opencv:4.5.2  
https://github.com/opencv/opencv  
https://github.com/opencv/opencv_contrib

NDK最新 LTS 版本: 21.4.7075529  
https://developer.android.com/ndk/downloads

## 编译

### 下载opencv

国内访问可以用github.com.cnpmjs.org替换github.com加速

- 方式1:  
  整个镜像都会克隆下来,速度较慢   
  git clone https://github.com/opencv/opencv.git
- 方式2:   
  指定版本克隆  
  git clone -b 4.5.2 --depth=1 https://github.com/opencv/opencv.git
- 方式3:   
  直接从https://github.com/opencv/opencv下载, 然后解压到当前目录

opencv_contrib的方式同上

### 目录结构

```
---
  |----build-opencv-android.sh  ①
  |----opencv                   ②
  |----opencv_contrib           ③
  |----build                    ④
  |----android_opencv           ⑤
```

① 编译脚本  
② 下载的opencv源码  
③ 下载的opencv_contrib源码  
④ 编译临时文件   
⑤ 编译结果文件

### 编译

- 方式1:
  > ./build-opencv-android.sh /Users/xxx/soft/android-sdk-macosx/ndk/21.4.7075529
- 方式2:
  > export ANDROID_HOME=/Users/xxx/soft/android-sdk-macosx   
  > export ANDROID_NDK_HOME=/Users/xxx/soft/android-sdk-macosx/ndk/21.4.7075529   
  > ./build-opencv-android.sh

  如果系统已经设置了ANDROID_HOME和ANDROID_NDK_HOME环境变量, 则可忽略export

## 注意

编译过程中opencv会下载部分模型文件, 可能会较慢