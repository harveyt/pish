#!/bin/bash
#
# Install And Provision System On Machine - using pish.
#
# ================================================================================
# Configuration
#

PISH_URL=https://github.com/harveyt/pish.git
PISH_LOCAL_BIN=/usr/local/bin
PISH_LOCAL_LIB=/usr/local/lib/pish
PISH_PROJECT_ROOT=$HOME/Projects/pish
PISH_PROJECT_EXEC=$PISH_PROJECT_ROOT/lib/pish/exec

# ================================================================================
# Install
#

function ensure_1pass_binary()
{
    local name="$1" env="$2"
    local binpath
    
    if [[ -x $PISH_LOCAL_BIN/$name ]]; then
	echo "Using $name from $PISH_LOCAL_BIN ..."
	binpath=$PISH_LOCAL_BIN/$name
    else
	echo "Using $name from $PISH_PROJECT_EXEC ..."
	binpath=$PISH_PROJECT_EXEC/$name
    fi
    eval export $env=$binpath
}

function ensure_pish_installed()
{
    if [[ -d $PISH_LOCAL_LIB ]]; then
	echo "Using PISH_ROOT=$PISH_LOCAL_LIB ..."
	PISH_ROOT=$PISH_LOCAL_LIB
    else
	if [[ ! -d $PISH_PROJECT_ROOT ]]; then
	    echo "Installing pish from $PISH_URL to $PISH_PROJECT_ROOT ..."
	    git clone $PISH_URL $PISH_PROJECT_ROOT
	fi
	echo "Using PISH_ROOT=$PISH_PROJECT_ROOT ..."
	PISH_ROOT=$PISH_PROJECT_ROOT
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
