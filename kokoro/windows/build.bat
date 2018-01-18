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

:: Force usage of python 2.7 rather than 3.6
set PATH=C:\python27;%PATH%

cd %SRC%\third_party
git clone https://github.com/google/googletest.git
git clone https://github.com/google/glslang.git
git clone https://github.com/KhronosGroup/SPIRV-Tools.git spirv-tools
git clone https://github.com/KhronosGroup/SPIRV-Headers.git spirv-headers

cd %SRC%
mkdir build
cd %SRC%\build

:: set up msvc build env
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86_amd64

:: #########################################
:: Invoke the build.
:: #########################################
echo "Starting build... %DATE% %TIME%"
if "%KOKORO_GITHUB_COMMIT%." == "." (
  set BUILD_SHA=%KOKORO_GITHUB_PULL_REQUEST_COMMIT%
) else (
  set BUILD_SHA=%KOKORO_GITHUB_COMMIT%
)
cmake -DCMAKE_C_COMPILER="C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/bin/cl.exe" -DCMAKE_CXX_COMPILER="C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/bin/cl.exe" -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
if %ERRORLEVEL% GEQ 1 exit /b %ERRORLEVEL%
ninja
if %ERRORLEVEL% GEQ 1 exit /b %ERRORLEVEL%
echo "Build Completed %DATE% %TIME%"

:: #########################################
:: Run the tests.
:: #########################################
echo "Running Tests... %DATE% %TIME%"
::ctest
ctest -C RelWithDebInfo
echo "Tests Completed %DATE% %TIME%"
exit /b %ERRORLEVEL%

