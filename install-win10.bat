@echo off

rem ================================================================================
rem Derived from https://github.com/miguelgrinberg/cygwin-installer/blob/master/install-cygwin.bat

rem Local variables to script only
setlocal

rem ================================================================================
rem Configuration

rem Where cygwin set will be downloaded from.
set CYGWIN_SETUP_EXE=setup-x86_64.exe
set CYGWIN_SETUP_URL=https://cygwin.com/%CYGWIN_SETUP_EXE%

rem Where cygwin will be downloaded from.
set CYGWIN_MIRROR_URL=http://mirror.csclub.uwaterloo.ca/cygwin/

rem Where cygwin will be placed. By default C:\Users\<username>\cygwin
set CYGWIN_BASE=%USERPROFILE%\cygwin

rem Where downloaded packages will be stored.
set CYGWIN_PKG_CACHE=%CYGWIN_BASE%\var\cache\apt\packages

rem Where the apt-cyg version is located.
set APT_CYG_URL=https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg

rem ================================================================================

if not exist %CYGWIN_BASE% goto install
ECHO The directory %CYGWIN_BASE% already exists.
ECHO Cannot install over an existing installation.
goto exit

:install

echo Creating Cygwin in %CYGWIN_BASE% ...
mkdir "%CYGWIN_BASE%"
cd %CYGWIN_BASE%

echo Downloading %CYGWIN_SETUP_EXE% from %CYGWIN_SETUP_URL% ...
curl -L -J %CYGWIN_SETUP_URL% -o %CYGWIN_SETUP_EXE%

:exit
