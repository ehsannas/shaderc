#!/bin/bash

# Fail on any error.
set -e
# Display commands being run.
set -x

echo $PWD
source ./build.sh x86
