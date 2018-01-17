set PATH=C:\Program Files\Java\jdk1.7.0_75\bin;%PATH%

cd %KOKORO_PIPER_DIR%\google3\experimental\users\ehsann\basic-project

rem Avoid checking out HEAD due to Windows-unfriendly filenames
git clone -n https://github.com/leachim6/hello-world.git
cd hello-world
rem Checkout only the file we plan on compiling at a known commit
git checkout 3bab02464b0fdc7c0e59cd39744ea432ec2baafa j/Java.java
cd j
javac Java.java

exit %ERRORLEVEL%
