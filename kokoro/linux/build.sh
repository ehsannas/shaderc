#!/bin/bash


# Fail on any error.
set -e
# Display commands being run.
set -x

BUILD_ROOT=$PWD
SRC=$PWD/github/shaderc
CONFIG=$1

SKIP_TESTS="False"
BUILD_TYPE="Debug"

# Possible configurations are:
# ASAN, COVERAGE, RELEASE, DEBUG, DEBUG_EXCEPTION, RELEASE_MINGW

if [[ $CONFIG = "Release" || $CONFIG = "RELEASE_MINGW" ]]
then
  BUILD_TYPE="RelWithDebInfo"
fi

ADDITIONAL_CMAKE_FLAGS=""
if [ $CONFIG = "ASAN" ]
then
  ADDITIONAL_CMAKE_FLAGS="-DCMAKE_CXX_FLAGS=-fsanitize=address -DCMAKE_C_FLAGS=-fsanitize=address -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
  export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-3.4
elif [ $CONFIG = "COVERAGE" ]
then
  ADDITIONAL_CMAKE_FLAGS="-DENABLE_CODE_COVERAGE=ON"
  SKIP_TESTS="True"
elif [ $CONFIG = "DEBUG_EXCEPTION" ]
then
  ADDITIONAL_CMAKE_FLAGS="-DDISABLE_EXCEPTIONS=ON -DDISABLE_RTTI=ON"
elif [ $CONFIG = "RELEASE_MINGW" ]
then
  ADDITIONAL_CMAKE_FLAGS="-Dgtest_disable_pthreads=ON -DCMAKE_TOOLCHAIN_FILE=$SRC/cmake/linux-mingw-toolchain.cmake"
  SKIP_TESTS="True"
fi

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
cmake -GNinja -DRE2_BUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=$BUILD_TYPE $ADDITIONAL_CMAKE_FLAGS ..

echo $(date): Build glslang...
ninja glslangValidator

echo $(date): Build everything...
ninja
echo $(date): Build completed.

echo $(date): Check Shaderc for copyright notices...
ninja check-copyright

if [ $CONFIG = "COVERAGE" ]
then
  echo $(date): Check coverage...
  ninja report-coverage
  echo $(date): Check coverage completed.
fi

echo $(date): Starting ctest...
if [ $SKIP_TESTS = "False" ]
then
  ctest
fi
echo $(date): ctest completed.

