FROM debian:9
MAINTAINER nyxgear <dev@nyxgear.com>

##################################
# BUILDING STAGE 0
##################################

# Update dependencies
RUN apt-get update && \
    apt-get upgrade -y

# Install required packages
RUN apt-get install -y  \
    curl                \
    wget                \
    build-essential     \
    python              \
    git                 \
    cmake

RUN apt-get autoremove

# Create installation dir
RUN mkdir /ibm-pisa

# Trigger the next build stage
RUN curl -X POST https://registry.hub.docker.com/u/nyxgear/ibm-pisa/trigger/90555bcd-a079-4319-b2a4-108014dccf61/ \
         -H "Content-Type: application/json" --data '{"source_type": "Branch", "source_name": "stage-1"}'
