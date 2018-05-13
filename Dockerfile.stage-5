FROM nyxgear/ibm-pisa:stage-4
MAINTAINER nyxgear <dev@nyxgear.com>

##################################
# BUILDING STAGE 5
##################################

WORKDIR /ibm-pisa

ENV LLVM_ROOT=/ibm-pisa

# 4. OpenMP installation
# Download the OpenMP runtime library and extract the archive:
# https://www.openmprtl.org/download#stable-releases
RUN cd $LLVM_ROOT                                                               && \
    wget https://www.openmprtl.org/sites/default/files/libomp_20160808_oss.tgz  && \
    tar -xzvf libomp_20160808_oss.tgz                                           && \
    cd libomp_oss                                                               && \
    OPENMP_DIR=$(pwd)                                                           && \
    make compiler=gcc

# Trigger the next build stage
RUN curl -X POST https://registry.hub.docker.com/u/nyxgear/ibm-pisa/trigger/90555bcd-a079-4319-b2a4-108014dccf61/ \
         -H "Content-Type: application/json" --data '{"source_type": "Branch", "source_name": "master"}'
