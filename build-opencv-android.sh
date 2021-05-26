#!/bin/bash

# eg: ./build-opencv-android.sh /Users/xxx/android-sdk-macosx/ndk/21.xxx

function error_exit() {
  #  echo -en "\e[1;33;41m $1 \e[0m"
  echo "$1"
  exit
}

ANDROID_NDK="${1:-${ANDROID_NDK_HOME}}"
if [ -z $ANDROID_NDK ]; then
  error_exit "error: Must be specified ANDROID_NDK or ANDROID_NDK_HOME
eg1:
  export ANDROID_NDK_HOME=/Users/xxx/android-sdk-macosx/ndk/21.xxx
  ./build-opencv-android.sh

eg2:
  ./build-opencv-android.sh /Users/xxx/android-sdk-macosx/ndk/21.xxx
  " 1>&2
fi

if [ -z $ANDROID_HOME ]; then
  # 现在android sdk目录结构一般是sdk/ndk/21.xxx
  ANDROID_HOME=${ANDROID_NDK}/../..
fi

######### 基本参数
OPENCV_DIR_NAME="opencv"
OPENCV_CONTRIB_DIR_NAME="opencv_contrib"
ANDROID_NDK_HOME=${ANDROID_NDK}
ANDROID_SDK=${ANDROID_HOME}
CMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake
#SCRIPT=$(readlink -f $0) # mac不支持readlink -f
#PROJECT_DIR=`dirname $SCRIPT`
PROJECT_DIR=$(pwd $0)
OPENCV_ROOT="${PROJECT_DIR}/${OPENCV_DIR_NAME}"
N_JOBS=${N_JOBS:-4}
INSTALL_DIR="${PROJECT_DIR}/android_opencv"
TEMP_BUILD_ROOT_DIR="${PROJECT_DIR}/build"

### ABIs
declare -a ANDROID_ABI_LIST=(
  #  "armeabi"  #最新版本ndk已经弃用了, 如果需要,ndk版本选择20-
  "armeabi-v7a"
  "arm64-v8a"
  "x86"
  "x86_64"
  #  "mips"
  #  "mips64"
)

############## 设置系统的环境变量
export ANDROID_NDK=${ANDROID_NDK}
export ANDROID_SDK=${ANDROID_NDK}/../..
# 编译android工程使用
export ANDROID_HOME=${ANDROID_SDK}
export ANDROID_NDK_HOME=${ANDROID_NDK}

echo "ANDROID_NDK_HOME=${ANDROID_NDK_HOME}"
echo "ANDROID_HOME=${ANDROID_HOME}"
echo "CMAKE_TOOLCHAIN_FILE" ${CMAKE_TOOLCHAIN_FILE}
echo "ANDROID_ABI_LIST=${ANDROID_ABI_LIST[*]}"

################
function build() {
  old_dir=$(pwd)
  ANDROID_ABI="$1"

  if [ "${ANDROID_ABI}" = "armeabi" ]; then
    API_LEVEL=19
  else
    API_LEVEL=21
  fi

  temp_build_dir="${TEMP_BUILD_ROOT_DIR}/android_${ANDROID_ABI}"
  #    rm -rf "${temp_build_dir}"
  mkdir -p "${temp_build_dir}"
  echo "temp_build_dir:" ${temp_build_dir}
  cd "${temp_build_dir}"

  #  current_install_dir="${INSTALL_DIR}/opencv_${ANDROID_ABI}"
  current_install_dir="${INSTALL_DIR}/opencv"

  cmake -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_TOOLCHAIN_FILE="${CMAKE_TOOLCHAIN_FILE}" \
    -DANDROID_NDK="${ANDROID_NDK}" \
    -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
    -DANDROID_ABI="${ANDROID_ABI}" \
    -D WITH_CUDA=OFF \
    -D WITH_MATLAB=OFF \
    -D BUILD_ANDROID_EXAMPLES=OFF \
    -D BUILD_DOCS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_TESTS=OFF \
    -DOPENCV_EXTRA_MODULES_PATH="${PROJECT_DIR}/${OPENCV_CONTRIB_DIR_NAME}/modules/" \
    -DCMAKE_INSTALL_PREFIX="${current_install_dir}" \
    ${OPENCV_ROOT}
  make -j${N_JOBS}
  make install/strip
  #    rm -rf "${temp_build_dir}"
  cd $old_dir
}

for abi in "${ANDROID_ABI_LIST[@]}"; do
  echo "Start building Android&${abi}"
  build "${abi}"
  echo "End building Android&${abi}"
done

## 其他参数
#  -DBUILD_JAVA=OFF \
#  -DBUILD_ANDROID_EXAMPLES=OFF \
#  -DBUILD_ANDROID_PROJECTS=OFF \
#  -DANDROID_STL=c++_shared \
#  -DBUILD_SHARED_LIBS=ON \
#  -DANDROID_SDK_ROOT="/home/xxxx/Android/Sdk" \
