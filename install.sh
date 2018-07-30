#!/bin/bash
#
# Install And Provision System On Machine - using pish.
#
# ================================================================================
# Configuration
#

PISH_URL=https://github.com/harveyt/pish/archive/master.zip

# Preference order for finding binaries and scripts:
# - /usr/local
# - $HOME/Projecs/
# - $HOME/Downloads/
PISH_LOCAL_BIN=/usr/local/bin
PISH_LOCAL_LIB=/usr/local/lib/pish
PISH_PROJECT_ROOT=$HOME/Projects/pish
PISH_PROJECT_EXEC=$PISH_PROJECT_ROOT/lib/pish/exec
PISH_DOWNLOAD_ROOT=$HOME/Downloads/pish
PISH_DOWNLOAD_EXEC=$PISH_DOWNLOAD_ROOT/lib/pish/exec

# Private box configuration
BOX_1PASS_TAG=Bitbucket
BOX_URL=https://bitbucket.org/harveyt/box-macosx-harveyt/get/master.zip
BOX_DL=$HOME/Downloads/box.zip
BOX_ROOT=$HOME/Downloads/box

CURL=curl -L -J

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
    elif [[ -x $PISH_DOWNLOAD_EXEC/$name ]]; then
	binpath=$PISH_DOWNLOAD_EXEC
    else
	echo "Cannot find $name in $PISH_LOCAL_BIN, $PISH_PROJECT_EXEC or $PISH_DOWNLOAD_EXEC" >&2
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
	if [[ ! -d $PISH_DOWNLOAD_ROOT ]]; then
	    echo "Installing pish from $PISH_URL to $PISH_DOWNLOAD_ROOT ..."
	    local dl=/tmp/pish.zip
	    $CURL -o $dl $PISH_URL
	    mkdir -p $PISH_DOWNLOAD_ROOT
	    unzip -d $PISH_DOWNLOAD_ROOT -o -x $dl
	    mv $PISH_DOWNLOAD_ROOT/pish-master/* $PISH_DOWNLOAD_ROOT
	    rmdir $PISH_DOWNLOAD_ROOT/pish-master
	fi
	rootpath=$PISH_DOWNLOAD_ROOT
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

function box_installed_EXEC()
{
    local bitbucket_user=$(1pass -u $BITBUCKET_1PASS_TAG)
    local bitbucket_password=$(1pass -p $BITBUCKET_1PASS_TAG)
    $CURL --user "$bitbucket_user:$bitbucket_password" -o $BOX_DL $BOX_URL
    mkdir -p $BOX_DIR
    unzip -d $BOX_DIR -o -x $BOX_DL
    local subdir=$(cd $BOX_DIR; echo *box*)
    mv $BOX_DIR/$subdir/* $BOX_DIR
    mv $BOX_DIR/$subdir/.??* BOX_DIR
    rmdir $BOX_DIR/$subdir
}

# ================================================================================
# Main
#

function converge_defaults()
{
    requirement 1pass_login
    requirement box_installed
}

converge "$@"

# echo "--------------------------------------------------------------------------------"
# echo
# echo "Starting bash in $BOX_DIR ..."
# echo "Run ./install.sh ..."
# echo
# cd $BOX_DIR
# bash
