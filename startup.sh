#!/bin/bash

# This script is executed by default each time the docker container is run.

# Execute the hook shell script if any
if [ -f /llvm-root/ibm-pisa/example-compile-profile/compile/app/docker-startup-hook.sh ]; then
    echo "File /llvm-root/ibm-pisa/example-compile-profile/compile/app/docker-startup-hook.sh found!"
    echo "Executing..."
    source /llvm-root/ibm-pisa/example-compile-profile/compile/app/docker-startup-hook.sh
fi

# Fall back on bash execution to do not let the container automatically exit
bash
