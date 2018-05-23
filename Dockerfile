FROM nyxgear/ibm-pisa:stage-2
MAINTAINER nyxgear <dev@nyxgear.com>

######################################################
# IBM-PISA TOOL final installation stage
######################################################

ENV TMP_LLVM_SAMPLE_SRC=$LLVM_ROOT/llvm-3.4/projects/sample


# 8. Install the LLVM Pass (this pass instruments the LLVM bitcode with library calls)
# First, prepare the passCoupled folder (the same applies for passDecoupled) to have the following structure:

#############################################################
# passCoupled
#############################################################
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



#############################################################
# passDecoupled
#############################################################
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

