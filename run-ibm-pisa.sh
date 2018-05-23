#!/bin/bash
# Shortcut script to run properly the ibmp-pisa docker container

docker run --rm -it -v $PWD:/llvm-root/ibm-pisa/example-compile-profile/compile/app nyxgear/ibm-pisa
