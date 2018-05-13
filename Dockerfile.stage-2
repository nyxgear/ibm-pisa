FROM nyxgear/ibm-pisa:stage-1
MAINTAINER nyxgear <dev@nyxgear.com>

##################################
# BUILDING STAGE 2
##################################

WORKDIR /ibm-pisa

ENV LLVM_ROOT=/ibm-pisa

# 3. Configure, compile and install clang
# We will use clang with openMP support (x86_64 architectures).
# For other architectures use the official clang version.
RUN cd $LLVM_ROOT                                                               && \
    git clone https://github.com/clang-omp/clang llvm-3.4/tools/clang           && \
    cd llvm-3.4/tools/clang                                                     && \
    git checkout 34 # clang version for LLVM 3.4


# Trigger the next build stage
RUN curl -X POST https://registry.hub.docker.com/u/nyxgear/ibm-pisa/trigger/90555bcd-a079-4319-b2a4-108014dccf61/ \
         -H "Content-Type: application/json" --data '{"source_type": "Branch", "source_name": "stage-3"}'
