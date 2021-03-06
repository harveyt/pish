#!/bin/bash
#
# Install And Provision System On Machine - using pish.
#
# ================================================================================
# Configuration
#

PISH_URL=https://github.com/harveyt/pish/archive/master.zip
PISH_LOCAL=/cygdrive/z/harveyt/tmp/pish-master.zip

case $(uname -s) in
    Darwin)
	OS_CONFIG=mac
	BOX_CONFIG=box-macosx-harveyt
	;;
    CYGWIN_NT-10.0)
	OS_CONFIG=win10
	BOX_CONFIG=box-win10-harveyt
	;;
    *)
	echo "Unknown operating system: $(uname -s)" >&2
	exit 1
	;;
esac

# Preference order for finding binaries and scripts:
# - /usr/local
# - $HOME/Projects/pish
# - $HOME/tmp/provision/pish
PISH_LOCAL_BIN=/usr/local/bin
PISH_LOCAL_LIB=/usr/local/lib/pish
PISH_PROJECT_ROOT=$HOME/Projects/pish
PISH_PROJECT_EXEC=$PISH_PROJECT_ROOT/lib/pish/exec/$OS_CONFIG
PISH_PROVISION_ROOT=$HOME/tmp/provision/pish
PISH_PROVISION_EXEC=$PISH_PROVISION_ROOT/lib/pish/exec/$OS_CONFIG

# Private box configuration
BITBUCKET_1PASS_TAG=Bitbucket
BOX_URL=https://bitbucket.org/harveyt/$BOX_CONFIG/get/master.zip
BOX_LOCAL=/cygdrive/z/harveyt/tmp/$BOX_CONFIG-master.zip
BOX_DL=$HOME/tmp/provision/box.zip
BOX_ROOT=$HOME/tmp/provision/box

CURL="curl -L -J -#"

# ================================================================================
# Install
#

function ensure_1pass_binary()
{
    local name="$1" env="$2"
    local binpath
    
    if [[ -x $PISH_LOCAL_BIN/$name ]]; then
	binpath=$PISH_LOCAL_BIN
    elif [[ -x $PISH_PROJECT_EXEC/$name ]]; then
	binpath=$PISH_PROJECT_EXEC
    elif [[ -x $PISH_PROVISION_EXEC/$name ]]; then
	binpath=$PISH_PROVISION_EXEC
    else
	echo "Cannot find $name in:
	$PISH_LOCAL_BIN
	$PISH_PROJECT_EXEC
	$PISH_PROVISION_EXEC" >&2
	exit 1
    fi
    echo "Using $name from $binpath ..."
    eval export $env=$binpath/$name
}

function ensure_pish_installed()
{
    local rootpath
    
    if [[ -d $PISH_LOCAL_LIB ]]; then
	rootpath=$PISH_LOCAL_LIB
    elif [[ -d $PISH_PROJECT_ROOT ]]; then
	rootpath=$PISH_PROJECT_ROOT
    else
	if [[ ! -d $PISH_PROVISION_ROOT ]]; then
	    if [[ -f $PISH_LOCAL ]]; then
		echo "Using local $PISH_LOCAL ..."
		PISH_URL=file://$PISH_LOCAL
	    fi
		
	    echo "Installing pish from $PISH_URL to $PISH_PROVISION_ROOT ..."
	    local dl=/tmp/pish.zip
	    $CURL -o $dl $PISH_URL
	    mkdir -p $PISH_PROVISION_ROOT
	    unzip -d $PISH_PROVISION_ROOT -o -x $dl
	    mv $PISH_PROVISION_ROOT/pish-master/* $PISH_PROVISION_ROOT
	    rmdir $PISH_PROVISION_ROOT/pish-master
	fi
	rootpath=$PISH_PROVISION_ROOT
    fi
    echo "Using PISH_ROOT=$rootpath ..."
    export PISH_ROOT=$rootpath
}

ensure_pish_installed
ensure_1pass_binary 1pass _1PASS
ensure_1pass_binary op _1PASS_OP
ensure_1pass_binary jq _1PASS_JQ

# ================================================================================
# Library

PISH_LIB=$PISH_ROOT/lib/pish
PISH=$PISH_ROOT/bin/pish

. $PISH
. $PISH_LIB/basic
. $PISH_LIB/1pass

# ================================================================================
# Box Install
#

function box_installed_PREQ()
{
    requirement 1pass_logged_in
}

function box_installed_DESC()
{
    echo "box installed"
}

function box_installed_TEST()
{
    [[ -d "$BOX_ROOT" ]]
}

function box_installed_SHELL()
{
    if [[ -f $BOX_LOCAL ]]; then
	echo "Using local $BOX_LOCAL ..."
	BOX_URL=file://$BOX_LOCAL
    fi

    $CURL --user "$BITBUCKET_USER:$BITBUCKET_PASSWORD" -o $BOX_DL $BOX_URL
    mkdir -p $BOX_ROOT
    unzip -d $BOX_ROOT -o -x $BOX_DL
    local subdir=$(cd $BOX_ROOT; echo *box*)
    mv $BOX_ROOT/$subdir/* $BOX_ROOT
    mv $BOX_ROOT/$subdir/.??* $BOX_ROOT
    rmdir $BOX_ROOT/$subdir
}

# ================================================================================
# Main
#

function converge_defaults()
{
    requirement 1pass_login
    requirement 1pass_get_user "$BITBUCKET_1PASS_TAG" BITBUCKET_USER
    requirement 1pass_get_password "$BITBUCKET_1PASS_TAG" BITBUCKET_PASSWORD
    requirement box_installed
}

converge "$@"

echo "--------------------------------------------------------------------------------"
echo
echo "Starting bash in $BOX_ROOT ..."
echo "Run ./provision.sh ..."
echo
cd $BOX_ROOT
bash
