#!/bin/bash

# Fail on any error.
set -e
# Display commands being run.
set -x

SCRIPT_DIR=`dirname "$BASH_SOURCE"`
source $SCRIPT_DIR/build.sh "armeabi-v7a with NEON"
