#!/bin/bash

# Mind that the current working directory is:
# /llvm-root/ibm-pisa/example-compile-profile/compile/app

###################################### EXAMPLE ################################
# https://github.com/exabounds/ibm-pisa#testing-the-installation
cd ../app0
make pisa
export PISAFileName=out
export OMP_NUM_THREADS=1
./main.pisaCoupled.nls
cat out

exit
###############################################################################
