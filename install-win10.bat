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

rem Where the install.sh script can be loaded from.
set INSTALL_URL=https://github.com/harveyt/pish/raw/master/install.sh

rem Where the local development version install.sh script can be copied from.
set INSTALL_LOCAL=z:\harveyt\Projects\pish\install.sh

rem Where the users home should be
set HOME_DIR=home\%USERNAME%

rem Where the provision directory should be
set PROVISION_DIR=%HOME_DIR%\tmp\provision

rem Where the provision directory should be in Unix path
set UNIX_PROVISION_DIR=tmp/provision


rem ================================================================================

if not exist %CYGWIN_BASE% (
	echo Creating Cygwin in %CYGWIN_BASE% ...
	mkdir "%CYGWIN_BASE%"
)

cd /d %CYGWIN_BASE%

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

if not exist %HOME_DIR% (
	echo Set up home directory %HOME_DIR% ...
	bin\bash --login -c 'echo Done'
)

if not exist %PROVISION_DIR% (
	echo Create provision directory %PROVISION_DIR% ...
	md %PROVISION_DIR%
)

if not exist %PROVISION_DIR%\install.sh (
	if exist %INSTALL_LOCAL% (
		echo Copy local %UNIX_PROVISION_DIR%/install.sh ...
		copy %INSTALL_LOCAL% %PROVISION_DIR%\install.sh
	) else (
		echo Download %UNIX_PROVISION_DIR%/install.sh ...
		curl -L -J -# %INSTALL_URL% -o %PROVISION_DIR%\install.sh
	)
)

if exist %PROVISION_DIR%\install.sh (
 	echo Running %UNIX_PROVISION_DIR%/install.sh ...
 	bin\bash --login -c '%UNIX_PROVISION_DIR%/install.sh'
)
