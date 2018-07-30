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
    if [[ -d $PISH_LOCAL_LIB ]]; then
	echo "Using PISH_ROOT=$PISH_LOCAL_LIB ..."
	PISH_ROOT=$PISH_LOCAL_LIB
    elif [[ -d $PISH_PROJECT_ROOT ]]; then
	echo "Using PISH_ROOT=$PISH_PROJECT_ROOT ..."
	PISH_ROOT=$PISH_PROJECT_ROOT
    else
	if [[ ! -d $PISH_DOWNLOAD_ROOT ]]; then
	    echo "Installing pish from $PISH_URL to $PISH_DOWNLOAD_ROOT ..."
	    local dl=/tmp/pish.zip
	    curl -L -J -o $dl $PISH_URL
	    mkdir -p $PISH_DOWNLOAD_ROOT
	    unzip -d $PISH_DOWNLOAD_ROOT -o -x $dl
	    mv $PISH_DOWNLOAD_ROOT/pish-master/* $PISH_DOWNLOAD_ROOT
	    rmdir $PISH_DOWNLOAD_ROOT/pish-master
	fi
	echo "Using PISH_ROOT=$PISH_DOWNLOAD_ROOT ..."
	PISH_ROOT=$PISH_DOWNLOAD_ROOT
    fi

    ensure_1pass_binary 1pass _1PASS
    ensure_1pass_binary op _1PASS_OP
    ensure_1pass_binary jq _1PASS_JQ
}

ensure_pish_installed

# ================================================================================
# Library

PISH_LIB=$PISH_ROOT/lib/pish
PISH=$PISH_ROOT/bin/pish

. $PISH
. $PISH_LIB/basic
. $PISH_LIB/1pass

# ================================================================================
# Login
#

# ================================================================================
# Main
#

function converge_defaults()
{
    requirement 1pass_login
}

converge "$@"
