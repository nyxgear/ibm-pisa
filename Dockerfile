FROM nyxgear/ibm-pisa:stage-3
MAINTAINER nyxgear <dev@nyxgear.com>

##################################
# BUILDING STAGE 4
##################################

WORKDIR /ibm-pisa

ENV LLVM_ROOT=/ibm-pisa

# 4. Rebuild LLVM (configure, compile and install) - PT 2
ENV LLVM_ENABLE_THREADS=1
RUN cd $LLVM_ROOT                                                               && \
    cd llvm-build                                                               && \
    make install

# Trigger the next build stage
RUN curl -X POST https://registry.hub.docker.com/u/nyxgear/ibm-pisa/trigger/90555bcd-a079-4319-b2a4-108014dccf61/ \
         -H "Content-Type: application/json" --data '{"source_type": "Branch", "source_name": "stage-5"}'
