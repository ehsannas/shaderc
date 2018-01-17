#!/bin/bash


# Fail on any error.
set -e
# Display commands being run.
set -x

BUILD_ROOT=$PWD
SRC=$PWD/github/shaderc/

# Get NINJA.
wget -q https://github.com/ninja-build/ninja/releases/download/v1.7.2/ninja-linux.zip
unzip -q ninja-linux.zip

cd $SRC
git submodule update --init

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
cmake -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
ninja
echo $(date): Build completed.

echo $(date): Starting ctest...
ctest
echo $(date): ctest completed.

