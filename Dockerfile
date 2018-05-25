FROM debian:9
MAINTAINER nyxgear <dev@nyxgear.com>


################################################################################
# BUILDING STAGE 0
################################################################################

# Update dependencies
RUN apt-get update --fix-missing && \
    apt-get upgrade -y

# Install required packages
RUN apt-get install -y  \
    vim                 \
    curl                \
    wget                \
    build-essential     \
    python              \
    git                 \
    cmake               \
    groff               \
    autoconf            \
    libboost-all-dev    \
    libncurses5-dev     \
    lib32z1-dev

RUN apt-get autoremove

# Create llvm-root directory
RUN mkdir /llvm-root

WORKDIR /llvm-root

ENV LLVM_ROOT=/llvm-root

# 1. Get the LLVM source code
RUN wget -q http://llvm.org/releases/3.4/llvm-3.4.src.tar.gz                    && \
    tar -xzvf llvm-3.4.src.tar.gz


# 3. Configure, compile and install clang
# We will use clang with openMP support (x86_64 architectures).
# For other architectures use the official clang version.
RUN cd $LLVM_ROOT                                                               && \
    git clone https://github.com/clang-omp/clang llvm-3.4/tools/clang           && \
    cd llvm-3.4/tools/clang                                                     && \
    git checkout 34 # clang version for LLVM 3.4
# 4. Rebuild LLVM (configure, compile and install)

# Configure, compile and install LLVM is done only once: with also included clang

# 2. Configure, compile and install LLVM
ENV LLVM_ENABLE_THREADS=1
RUN cd $LLVM_ROOT                                                               && \
    mkdir llvm-build                                                            && \
    mkdir llvm-install                                                          && \
    cd llvm-build                                                               && \
    ../llvm-3.4/configure --enable-optimized --prefix=$LLVM_ROOT/llvm-install   && \
    make -j4                                                                    && \
    make install


################################################################################
# BUILDING STAGE 1
################################################################################

WORKDIR /llvm-root

ENV LLVM_ROOT=/llvm-root
ENV OPENMP_DIR=/llvm-root/libomp_oss
ENV MPI_DIR=/llvm-root/openmpi-1.10.2

# 5. OpenMP installation
# Download the OpenMP runtime library and extract the archive:
# https://www.openmprtl.org/download#stable-releases
RUN cd $LLVM_ROOT                                                               && \
    wget https://www.openmprtl.org/sites/default/files/libomp_20160808_oss.tgz  && \
    tar -xzvf libomp_20160808_oss.tgz                                           && \
    cd $OPENMP_DIR                                                              && \
    make compiler=gcc

# 6. OpenMPI installation
# Install OpenMPI and extract the archive (currently tested versions: 1.8.6 and 1.10.2):
# http://www.open-mpi.org/software/ompi/
RUN cd $LLVM_ROOT                                                               && \
    wget https://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.2.tar.gz && \
    tar -xzvf openmpi-1.10.2.tar.gz                                             && \
    cd $MPI_DIR                                                                 && \
    ./configure --prefix $MPI_DIR                                               && \
    make all install

# 7. RapidJSON installation
# If cmake is not install, run: sudo apt-get install cmake
RUN cd $LLVM_ROOT                                                               && \
    git clone https://github.com/miloyip/rapidjson                              && \
    cd rapidjson                                                                && \
    mkdir build                                                                 && \
    cd build                                                                    && \
    cmake ..                                                                    && \
    make
# The user might need to edit the file 'rapidjson/build/example/CMakeFiles/lookaheadparser.dir/flags.make':
# Remove flags -Weffc++ and -Wswitch-default




################################################################################
# BUILDING STAGE 2
################################################################################

WORKDIR /llvm-root

ENV LLVM_ROOT=/llvm-root
ENV ANALYSIS_ROOT_DIR=/llvm-root/ibm-pisa


# 8. Configure and compile the analysis pass and the library
RUN cd $LLVM_ROOT                                                               && \
    git clone https://github.com/exabounds/ibm-pisa.git
    # cd ibm-pisa
    # export ANALYSIS_ROOT_DIR=$(pwd)
    # Copy my_env.sh and set the local paths.
    # (Re)Edit the my_env.sh file to change the paths accordingly.
    # source my_env.sh

# seting up env variables

# set to $LLVM_ROOT/llvm-install
ENV PISA_ROOT=/llvm-root
ENV LLVM_INSTALL=$PISA_ROOT/llvm-install
ENV LLVM_BUILD=$PISA_ROOT/llvm-build
ENV LLVM_SRC=$PISA_ROOT/llvm-3.4

# set to $OPENMP_DIR
ENV OPENMP_DIR=$PISA_ROOT/libomp_oss

# set to $MPI_DIR
ENV MPI_DIR=$PISA_ROOT/openmpi-1.10.2

# set to include dir of rapidjson library
ENV RAPID_JSON=$PISA_ROOT/rapidjson/include

ENV PATH=$MPI_DIR/bin:$LLVM_INSTALL/bin:$PATH

ENV C_INCLUDE_PATH=$MPI_DIR/include:$LLVM_INSTALL/include:$OPENMP_DIR/exports/common/include
ENV C_INCLUDE_PATH=$RAPID_JSON:$C_INCLUDE_PATH
ENV CPLUS_INCLUDE_PATH=$MPI_DIR/include:$LLVM_INSTALL/include:$OPENMP_DIR/exports/common/include
ENV CPLUS_INCLUDE_PATH=$RAPID_JSON:$CPLUS_INCLUDE_PATH

ENV LIBRARY_PATH=$MPI_DIR/lib:$MPI_DIR/lib/openmpi:$LLVM_INSTALL/lib:$OPENMP_DIR/exports/lin_32e/lib
ENV LD_LIBRARY_PATH=$MPI_DIR/lib:$MPI_DIR/lib/openmpi:$LLVM_INSTALL/lib:$OPENMP_DIR/exports/lin_32e/lib
ENV LD_RUN_PATH=$MPI_DIR/lib:$MPI_DIR/lib/openmpi:$LD_RUN_PATH

# AFTER building the analysis pass:


# # Set ANALYSIS_LIB_PATH
ENV COUPLED_PASS_PATH=$PISA_ROOT/analysis-install/lib
# ENV DECOUPLED_PASS_PATH=$PISA_ROOT/PISApass-decoupled-install/lib

# Set LIB_PATH
ENV PISA_LIB_PATH=$PISA_ROOT/ibm-pisa/library

ENV LD_LIBRARY_PATH=$PISA_LIB_PATH:$LD_LIBRARY_PATH

## This variable is used for automatic generation and verification of tests outputs
ENV PISA_EXAMPLES=$PISA_ROOT/ibm-pisa/example-compile-profile

## Analyze FORTRAN code with Dragonegg + LLVM-3.5.2
# ENV GCC=gcc-4.8
# ENV CC=gcc-4.8
# ENV CXX=g++-4.8
# ENV CFORTRAN=gcc-4.8
# ENV DRAGONEGG_PATH=$PISA_ROOT/dragonegg-3.5.2.src
# ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PISA_LIB_PATH:$DRAGONEGG_PATH
# ENV LIBRARY_PATH=$LIBRARY_PATH:$PISA_LIB_PATH:$DRAGONEGG_PATH

## Additional PISA inputs and outputs
# ENV PISAFileName=output.json
# ENV AddJSONData=header.json

## Print PISA output in JSON pretty print
ENV PRETTYPRINT=$PISA_ROOT/ibm-pisa/example-compile-profile/prettyPrint.sh





################################################################################
# BUILDING STAGE: final installation stage
################################################################################
ENV TMP_LLVM_SAMPLE_SRC=$LLVM_ROOT/llvm-3.4/projects/sample


# 8. Install the LLVM Pass (this pass instruments the LLVM bitcode with library calls)
# First, prepare the passCoupled folder (the same applies for passDecoupled) to have the following structure:

##############
# passCoupled
##############
RUN cd $PISA_ROOT/ibm-pisa                                                              && \
    cd passCoupled                                                                      && \

        # Makefile                    copy $TMP_LLVM_SAMPLE_SRC/Makefile and change DIRS from 'lib tools' to 'lib'
        cp $TMP_LLVM_SAMPLE_SRC/Makefile .                                              && \
        sed -i 's/lib\ tools/lib/g' Makefile                                            && \

        # Makefile.common.in          copy $TMP_LLVM_SAMPLE_SRC/Makefile.common.in, change PROJECT_NAME to 'Analysis' and add PROJ_VERSION=0.1
        cp $TMP_LLVM_SAMPLE_SRC/Makefile.common.in .                                    && \
        sed -i 's/^PROJECT_NAME := .*$/PROJECT_NAME := Analysis/g' Makefile.common.in   && \
        sed -i 's/^PROJ_VERSION := .*$/PROJ_VERSION := 0.1/g' Makefile.common.in        && \

        # Makefile.llvm.config.in     copy $TMP_LLVM_SAMPLE_SRC/Makefile.llvm.config.in
        cp $TMP_LLVM_SAMPLE_SRC/Makefile.llvm.config.in .                               && \

        # Makefile.llvm.rules         copy $TMP_LLVM_SAMPLE_SRC/Makefile.llvm.rules
        cp $TMP_LLVM_SAMPLE_SRC/Makefile.llvm.rules .                                   && \

        # lib/                        already created
        cd lib                                                                          && \

            # Makefile                copy $TMP_LLVM_SAMPLE_SRC/lib/Makefile and change DIRS to 'Analysis'
            cp $TMP_LLVM_SAMPLE_SRC/lib/Makefile .                                      && \
            sed -i 's/^DIRS=.*$/DIRS=Analysis/g' Makefile                               && \


            # Analysis/               already created
            cd Analysis                                                                 && \

                # Analysis.cpp        already provided

                # Makefile            copy $TMP_LLVM_SAMPLE_SRC/lib/sample/Makefile, change LIBRARYNAME to 'Analysis' and add LOADABLE_MODULE=1
                cp $TMP_LLVM_SAMPLE_SRC/lib/sample/Makefile .                                       && \
                sed -i 's/^LIBRARYNAME=.*$/LIBRARYNAME=Analysis\n\nLOADABLE_MODULE=1/g' Makefile    && \
            cd ../..                                                                    && \

    # autoconf/                      copy $TMP_LLVM_SAMPLE_SRC/autoconf
    cp -r $TMP_LLVM_SAMPLE_SRC/autoconf .                                               && \
    cd autoconf                                                                         && \

        # AutoRegen.sh            no changes required
        # config.guess            no changes required
        # config.sub              no changes required

        # configure.ac            change AC_INIT by replacing 'SAMPLE' with 'ANALYSIS' and by adding version number (0.01) and email address
        sed -i 's/SAMPLE/ANALYSIS/g' configure.ac                                       && \
        sed -i 's/x\.xx/0\.01/g' configure.ac                                           && \
        #                         change LLVM_SRC_ROOT to point to $LLVM_SRC ($LLVM_ROOT/llvm-3.4)
        sed -i "s|^LLVM_SRC_ROOT=.*$|LLVM_SRC_ROOT=$LLVM_SRC|g" configure.ac            && \
        #                         change LLVM_OBJ_ROOT to point to $LLVM_BUILD ($LLVM_ROOT/llvm-build)
        sed -i "s|^LLVM_OBJ_ROOT=.*$|LLVM_OBJ_ROOT=$LLVM_BUILD|g" configure.ac          && \
        #                         change AC_CONFIG_MAKEFILE(lib/sample/Makefile) by replacing 'sample' with 'Analysis'
        #                         change AC_CONFIG_MAKEFILE(tools/Analysis/Makefile) by replacing 'sample' with 'Analysis'
        sed -i "s|sample/Makefile|Analysis/Makefile|g" configure.ac

        # ExportMap.map           no changes required
        # install-sh              no changes required
        # LICENSE.txt             no changes required
        # ltmain.sh               no changes required

        # m4/                     already copied with the autoconf/ folder
        # mkinstalldirs           no changes required

# For the first installation of the pass, copy the full passCoupled (or passDecoupled) folder.
RUN cd $PISA_ROOT/ibm-pisa                                                              && \
    cp -r passCoupled $LLVM_ROOT/llvm-3.4/projects/Analysis

# # After each Analysis.cpp update, just copy the Analysis.cpp file from passCoupled (or passDecoupled).
# # Otherwise go to the next instruction.

RUN cd $LLVM_ROOT/llvm-3.4/projects/Analysis/autoconf                                   && \
    # modify LLVM_SRC_ROOT and LLVM_OBJ_ROOT in /projects/Analysis/autoconf/configure.ac:
    # LLVM_SRC_ROOT to $LLVM_ROOT/llvm-3.4 (or $LLVM_SRC is previously set in my_env.sh)
    # LLVM_OBJ_ROOT to $LLVM_ROOT/llvm-build (or $LLVM_BUILD is previously set in my_env.sh)
    # The user might need to run 'chmod u+x' on AutoRegen.sh.
    # If autoconf is not installed, the user should run 'sudo apt-get install autoconf'
    ./AutoRegen.sh

RUN cd $LLVM_ROOT                                                                       && \
    mkdir analysis-build                                                                && \
    mkdir analysis-install                                                              && \
    cd analysis-build                                                                   && \
    $LLVM_ROOT/llvm-3.4/projects/Analysis/configure --with-llvmsrc=$LLVM_ROOT/llvm-3.4 --with-llvmobj=$LLVM_ROOT/llvm-build --prefix=$LLVM_ROOT/analysis-install  && \
    # for LLVM 3.5 or newer also add --enable-cxx11=yes
    # Run 'chmod u+x $LLVM_ROOT/llvm-3.4/projects/Analysis/autoconf/mkinstalldirs' for the following command to run succesfully.
    make && make install

# Library
RUN cd $ANALYSIS_ROOT_DIR/library                                               && \
    # If the boost libraries are not installed, run 'sudo apt-get install libboost-all-dev'.
    make coupled

# # In the 'my_env.sh' file, set COUPLED_PASS_PATH, PISA_LIB_PATH, PISA_EXAMPLES and PRETTYPRINT.
# # export COUPLED_PASS_PATH=$PISA_ROOT/analysis-install/lib
# # export PISA_LIB_PATH=$PISA_ROOT/ibm-pisa/library
# # export LD_LIBRARY_PATH=$PISA_LIB_PATH:$LD_LIBRARY_PATH
# # export PISA_EXAMPLES=$PISA_ROOT/ibm-pisa/example-compile-profile
# # export PRETTYPRINT=$PISA_ROOT/ibm-pisa/example-compile-profile/prettyPrint.sh
# # After setting these variables, run 'source my_env.sh'.


################
# passDecoupled
################
RUN cd $PISA_ROOT/ibm-pisa                                                              && \
    cd passDecoupled                                                                    && \

        # Makefile                    copy $TMP_LLVM_SAMPLE_SRC/Makefile and change DIRS from 'lib tools' to 'lib'
        cp $TMP_LLVM_SAMPLE_SRC/Makefile .                                              && \
        sed -i 's/lib\ tools/lib/g' Makefile                                            && \

        # Makefile.common.in          copy $TMP_LLVM_SAMPLE_SRC/Makefile.common.in, change PROJECT_NAME to 'Analysis' and add PROJ_VERSION=0.1
        cp $TMP_LLVM_SAMPLE_SRC/Makefile.common.in .                                    && \
        sed -i 's/^PROJECT_NAME := .*$/PROJECT_NAME := Analysis/g' Makefile.common.in   && \
        sed -i 's/^PROJ_VERSION := .*$/PROJ_VERSION := 0.1/g' Makefile.common.in        && \

        # Makefile.llvm.config.in     copy $TMP_LLVM_SAMPLE_SRC/Makefile.llvm.config.in
        cp $TMP_LLVM_SAMPLE_SRC/Makefile.llvm.config.in .                               && \

        # Makefile.llvm.rules         copy $TMP_LLVM_SAMPLE_SRC/Makefile.llvm.rules
        cp $TMP_LLVM_SAMPLE_SRC/Makefile.llvm.rules .                                   && \

        # lib/                        already created
        cd lib                                                                          && \

            # Makefile                copy $TMP_LLVM_SAMPLE_SRC/lib/Makefile and change DIRS to 'Analysis'
            cp $TMP_LLVM_SAMPLE_SRC/lib/Makefile .                                      && \
            sed -i 's/^DIRS=.*$/DIRS=Analysis/g' Makefile                               && \


            # Analysis/               already created
            cd Analysis                                                                 && \

                # Analysis.cpp        already provided

                # Makefile            copy $TMP_LLVM_SAMPLE_SRC/lib/sample/Makefile, change LIBRARYNAME to 'Analysis' and add LOADABLE_MODULE=1
                cp $TMP_LLVM_SAMPLE_SRC/lib/sample/Makefile .                                       && \
                sed -i 's/^LIBRARYNAME=.*$/LIBRARYNAME=Analysis\n\nLOADABLE_MODULE=1/g' Makefile    && \
            cd ../..                                                                    && \

    # autoconf/                      copy $TMP_LLVM_SAMPLE_SRC/autoconf
    cp -r $TMP_LLVM_SAMPLE_SRC/autoconf .                                               && \
    cd autoconf                                                                         && \

        # AutoRegen.sh            no changes required
        # config.guess            no changes required
        # config.sub              no changes required

        # configure.ac            change AC_INIT by replacing 'SAMPLE' with 'ANALYSIS' and by adding version number (0.01) and email address
        sed -i 's/SAMPLE/ANALYSIS/g' configure.ac                                       && \
        sed -i 's/x\.xx/0\.01/g' configure.ac                                           && \
        #                         change LLVM_SRC_ROOT to point to $LLVM_SRC ($LLVM_ROOT/llvm-3.4)
        sed -i "s|^LLVM_SRC_ROOT=.*$|LLVM_SRC_ROOT=$LLVM_SRC|g" configure.ac            && \
        #                         change LLVM_OBJ_ROOT to point to $LLVM_BUILD ($LLVM_ROOT/llvm-build)
        sed -i "s|^LLVM_OBJ_ROOT=.*$|LLVM_OBJ_ROOT=$LLVM_BUILD|g" configure.ac          && \
        #                         change AC_CONFIG_MAKEFILE(lib/sample/Makefile) by replacing 'sample' with 'Analysis'
        #                         change AC_CONFIG_MAKEFILE(tools/Analysis/Makefile) by replacing 'sample' with 'Analysis'
        sed -i "s|sample/Makefile|Analysis/Makefile|g" configure.ac

        # ExportMap.map           no changes required
        # install-sh              no changes required
        # LICENSE.txt             no changes required
        # ltmain.sh               no changes required

        # m4/                     already copied with the autoconf/ folder
        # mkinstalldirs           no changes required

# For the first installation of the pass, copy the full passCoupled (or passDecoupled) folder.
RUN cd $PISA_ROOT/ibm-pisa                                                              && \
    cp -r passCoupled $LLVM_ROOT/llvm-3.4/projects/Analysis

# # After each Analysis.cpp update, just copy the Analysis.cpp file from passCoupled (or passDecoupled).
# # Otherwise go to the next instruction.

RUN cd $LLVM_ROOT/llvm-3.4/projects/Analysis/autoconf                                   && \
    # modify LLVM_SRC_ROOT and LLVM_OBJ_ROOT in /projects/Analysis/autoconf/configure.ac:
    # LLVM_SRC_ROOT to $LLVM_ROOT/llvm-3.4 (or $LLVM_SRC is previously set in my_env.sh)
    # LLVM_OBJ_ROOT to $LLVM_ROOT/llvm-build (or $LLVM_BUILD is previously set in my_env.sh)
    # The user might need to run 'chmod u+x' on AutoRegen.sh.
    # If autoconf is not installed, the user should run 'sudo apt-get install autoconf'
    ./AutoRegen.sh

RUN cd $LLVM_ROOT                                                                       && \
    cd analysis-build                                                                   && \
    $LLVM_ROOT/llvm-3.4/projects/Analysis/configure --with-llvmsrc=$LLVM_ROOT/llvm-3.4 --with-llvmobj=$LLVM_ROOT/llvm-build --prefix=$LLVM_ROOT/analysis-install  && \
    # for LLVM 3.5 or newer also add --enable-cxx11=yes
    # Run 'chmod u+x $LLVM_ROOT/llvm-3.4/projects/Analysis/autoconf/mkinstalldirs' for the following command to run succesfully.
    make && make install

# Library
RUN cd $ANALYSIS_ROOT_DIR/library                                               && \
    # If the boost libraries are not installed, run 'sudo apt-get install libboost-all-dev'.
    make decoupled

# # In the 'my_env.sh' file, set COUPLED_PASS_PATH, PISA_LIB_PATH, PISA_EXAMPLES and PRETTYPRINT.
# # export COUPLED_PASS_PATH=$PISA_ROOT/analysis-install/lib
# # export PISA_LIB_PATH=$PISA_ROOT/ibm-pisa/library
# # export LD_LIBRARY_PATH=$PISA_LIB_PATH:$LD_LIBRARY_PATH
# # export PISA_EXAMPLES=$PISA_ROOT/ibm-pisa/example-compile-profile
# # export PRETTYPRINT=$PISA_ROOT/ibm-pisa/example-compile-profile/prettyPrint.sh
# # After setting these variables, run 'source my_env.sh'.
# ```


################################################################################
# Finalize image
################################################################################
# remove useless build files
RUN cd /llvm-root                                                               && \
    rm -r analysis-build \
          libomp_20160808_oss.tgz \
          llvm-3.4.src.tar.gz \
          openmpi-1.10.2.tar.gz \
          llvm-build

# some aliases
RUN  echo "alias ll='ls -alF'\nalias la='ls -A'\nalias l='ls -CF'" > /root/.bashrc

# Copy the startup script
COPY startup.sh /startup.sh

RUN chmod +x /startup.sh                                                        && \
    mkdir /llvm-root/ibm-pisa/example-compile-profile/compile/app

WORKDIR /llvm-root/ibm-pisa/example-compile-profile/compile/app

# Execute the startup script if no other command overwrite the below one
CMD ["/startup.sh"]
