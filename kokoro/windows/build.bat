:: Copyright (C) 2017 Google Inc.
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.
::
:: Windows Build Script.

set BUILD_ROOT=%cd%
set SRC=%cd%\github\shaderc

# Ninja is available on windows instance.
#which ninja

cd %SRC%\third_party
git clone https://github.com/google/googletest.git
git clone https://github.com/google/glslang.git
git clone https://github.com/KhronosGroup/SPIRV-Tools.git spirv-tools
git clone https://github.com/KhronosGroup/SPIRV-Headers.git spirv-headers

cd %SRC%
mkdir build
cd %SRC%\build

# Invoke the build.
echo "Starting build..."
echo %DATE% %TIME%
if "%KOKORO_GITHUB_COMMIT%." == "." (
  set BUILD_SHA=%KOKORO_GITHUB_PULL_REQUEST_COMMIT%
) else (
  set BUILD_SHA=%KOKORO_GITHUB_COMMIT%
)
cmake -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
ninja
echo "Build Completed."
echo %DATE% %TIME%

echo "Running Tests..."
echo %DATE% %TIME%
ctest
echo "Tests Completed."
echo %DATE% %TIME%

