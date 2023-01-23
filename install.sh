#!/bin/bash
#
# Install And Provision System On Machine - using pish.
#
# ================================================================================
# Configuration
#

PISH_URL=https://github.com/harveyt/pish.git
PISH_LOCAL=$HOME/Projects/pish
PISH_BIN=$PISH_LOCAL/bin
PISH_HOST=$(hostname)

# --------------------------------------------------------------------------------
#

detect_box_os()
{
    case $(uname -s) in
	Darwin)
	    OS_CONFIG=macos
	    case $PISH_HOST in
		Harveys-MBP)
		    BOX_CONFIG=box-spartan-macos
		    ;;
		*)
		    echo "Unknown $OS_CONFIG host: $PISH_HOST" >&2
		    exit 1
		    ;;
	    esac
	    ;;
	Linux)
	    # Could be Linux or WSL2
	    case $(uname -r) in
		*-WSL2)
		    OS_CONFIG=linux-wsl2
		    case $PISH_HOST in
			panther)
			    BOX_CONFIG=box-panther-win
			    ;;
			*)
			    echo "Unknown $OS_CONFIG host: $PISH_HOST" >&2
			    exit 1
			    ;;
		    esac
		    ;;
		*)
		    echo "Linux native (non-WSL2) not yet supported" >&2
		    exit 1
		    ;;
	    esac
	    ;;
	*)
	    echo "Unknown operating system: $(uname -s)" >&2
	    exit 1
	    ;;
    esac
}

clone_pish()
{
    if [[ ! -d $PISH_LOCAL ]]; then
	echo "Cloning Pish into '$PISH_LOCAL'..."
	git clone $PISH_URL $PISH_LOCAL
    else
	echo "Updating Pish at '$PISH_LOCAL'..."
	(cd $PISH_LOCAL; git pull)
    fi
}

run_pish()
{
    $PISH_BIN/pish --box="$BOX_CONFIG" --os="$OS_CONFIG"
}

# ================================================================================
# Main

detect_box_os
clone_pish
run_pish
