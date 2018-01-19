#!/bin/bash


# Fail on any error.
set -e
# Display commands being run.
set -x

BUILD_ROOT=$PWD
SRC=$PWD/github/shaderc

# Get NINJA.
wget -q https://github.com/ninja-build/ninja/releases/download/v1.7.2/ninja-linux.zip
unzip -q ninja-linux.zip
export PATH="$PWD:$PATH"

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
cmake -DRE2_BUILD_TESTING=OFF -DCMAKE_MAKE_PROGRAM=ninja -GNinja -DCMAKE_BUILD_TYPE=Debug -DENABLE_CODE_COVERAGE=ON ..

echo $(date): Build glslang...
ninja glslangValidator

echo $(date): Build everything...
ninja

echo $(date): Check Shaderc for copyright notices...
ninja check-copyright

echo $(date): Build completed.

echo $(date): Check coverage...
ninja report-coverage
echo $(date): Check coverage completed.

# TODO: Upload code coverage stats
