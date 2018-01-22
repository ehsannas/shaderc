#!/bin/bash


# Fail on any error.
set -e
# Display commands being run.
set -x

BUILD_ROOT=$PWD
SRC=$PWD/github/shaderc
TARGET_ARCH=$1

# Get NINJA.
wget -q https://github.com/ninja-build/ninja/releases/download/v1.7.2/ninja-linux.zip
unzip -q ninja-linux.zip
export PATH="$PWD:$PATH"
export BUILD_NDK=ON
export CC=clang-3.6
export CXX=clang++-3.6
clang --version

git clone --depth=1 https://github.com/urho3d/android-ndk.git android-ndk
export ANDROID_NDK=$PWD/android-ndk
git clone --depth=1 https://github.com/taka-no-me/android-cmake.git android-cmake
export TOOLCHAIN_PATH=$PWD/android-cmake/android.toolchain.cmake


cd $SRC/third_party
git clone https://github.com/google/googletest.git
git clone https://github.com/google/glslang.git
git clone https://github.com/KhronosGroup/SPIRV-Tools.git spirv-tools
git clone https://github.com/KhronosGroup/SPIRV-Headers.git spirv-headers

cd $SRC/
mkdir build
cd $SRC/build

# Invoke the build.
BUILD_SHA=${KOKORO_GITHUB_COMMIT:-$KOKORO_GITHUB_PULL_REQUEST_COMMIT}
echo $(date): Starting build...
cmake -DRE2_BUILD_TESTING=OFF -GNinja -DCMAKE_BUILD_TYPE=Release -DANDROID_NATIVE_API_LEVEL=android-9 -DANDROID_ABI=$TARGET_ARCH -DSHADERC_SKIP_TESTS=ON -DSPIRV_SKIP_TESTS=ON -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_PATH -DANDROID_NDK=$ANDROID_NDK ..


echo $(date): Build glslang...
ninja glslangValidator

echo $(date): Build everything...
ninja

echo $(date): Check Shaderc for copyright notices...
ninja check-copyright

echo $(date): Build completed.
