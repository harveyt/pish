#!/bin/bash
#
# Install And Provision System On Machine - using pish.
#
# ================================================================================
# Configuration
#

PISH_URL="https://github.com/harveyt/pish.git"
PISH_ROOT="$HOME/Projects/pish"
GIT_ORIGIN=harveyt

export PISH_FAST=${PISH_FAST:-false}

# --------------------------------------------------------------------------------
clone_pish()
{
    if [[ ! -d $PISH_ROOT ]]; then
	echo "Cloning Pish into '$PISH_ROOT'..."
	git clone --origin=$GIT_ORIGIN $PISH_URL $PISH_ROOT
    else
	if ! $PISH_FAST; then
	    echo "Updating Pish at '$PISH_ROOT'..."
	    (cd $PISH_ROOT; git pull)
	fi
    fi
}

run_pish()
{
    $PISH_ROOT/bin/pish
}

# ================================================================================
# Main

clone_pish
run_pish
