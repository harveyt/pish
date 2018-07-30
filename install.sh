#!/bin/bash
#
# Install And Provision System On Machine - using pish.
#
# ================================================================================
# Configuration
#

PISH_URL=https://github.com/harveyt/pish.git
PISH_ROOT=$HOME/Projects/pish-TEST
PISH_LIB=$PISH_ROOT/lib/pish
PISH=$PISH_ROOT/bin/pish

# ================================================================================
# Install
#

function ensure_pish_installed()
{
    [[ -d $PISH_ROOT ]] && return
    echo "Installing pish from $PISH_URL to $PISH_ROOT ..."
    git clone $PISH_URL $PISH_ROOT
    echo ""    
}

ensure_pish_installed

# ================================================================================
# Library

. $PISH

# ================================================================================
# Main
#

function converge_defaults()
{
    true
}

converge "$@"
