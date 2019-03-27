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

rem Initial packages required to run base system and apt-cyg
set PACKAGES=wget,ca-certificates,gnupg
rem Initial packages required to run PISH install.sh
set PACKAGES=%PACKAGES%,curl,unzip

set PISH_URL=https://github.com/harveyt/pish/raw/master/install.sh

rem ================================================================================

if not exist %CYGWIN_BASE% (
	echo Creating Cygwin in %CYGWIN_BASE% ...
	mkdir "%CYGWIN_BASE%"
)

cd %CYGWIN_BASE%

if not exist %CYGWIN_SETUP_EXE% (
	echo Downloading %CYGWIN_SETUP_EXE% from %CYGWIN_SETUP_URL% ...
	curl -L -J -# %CYGWIN_SETUP_URL% -o %CYGWIN_SETUP_EXE%
)

if not exist bin (
	echo Set up Cygwin base installation ...
	%CYGWIN_SETUP_EXE% --no-admin ^
		--quiet-mode ^
		--root %CYGWIN_BASE% ^
		--site %CYGWIN_MIRROR_URL% ^
		--local-package-dir %CYGWIN_PKG_CACHE% ^
		--categories Base ^
		--packages %PACKAGES%
)

if not exist bin\apt-cyg (
 	echo Set up apt-cyg ...   
	bin\wget -O /bin/apt-cyg %APT_CYG_URL%
	bin\chmod +x /bin/apt-cyg
)

if not exist home\%USERNAME% (
	echo Set up home directory ...
	bin\bash --login -c 'echo Done'
)

if not exist home\%USERNAME%\install.sh (
	echo Download PISH install.sh ...
	curl -L -J -# %PISH_URL% -o home\%USERNAME%\install.sh
)

if exist home\%USERNAME%\Downloads\pish (
	echo Running PISH install.sh ...
	bin\bash --login -c './install.sh'	
)

