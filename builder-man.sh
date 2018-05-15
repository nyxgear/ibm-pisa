#!/bin/bash
echo_help() {
echo "
    This script is useful to automatically build the image sateges in sequence.
    
        ./build-helper.sh [-f | --from-stage <[0-9]+>]] [-t | --to-stage <[0-9]+>] [--complete-build] [--push] 


    It can be used to build the complete image, from stage-0 to the last one:
    ./build-helper.sh --complete-build

    or to build from stage-0 to a spacific stage:
    ./build-helper.sh --to-stage [0-9]+
        
    from one stage to the last one:
    ./build-helper.sh --from-stage [0-9]+

    or starting from one stage till another one:
    ./build-helper.sh --from-stage [0-9]+ --to-stage [0-9]+

    Also, if you want to push each stage once build add the parameter: --push
"
}

if [[ $# -eq 0 ]]; then 
    echo_help 
    exit
fi

# Repo name
REPO="nyxgear/ibm-pisa"

# Detect last stage file
LAST_STAGE_FILE=$(find . -name 'Dockerfile.stage-*' | sort | tail -n 1 -)
LAST_STAGE_NUMBER=$(echo $LAST_STAGE_FILE | sed "s/\.\/Dockerfile.stage-//g")

# Initialization
COMPLETE=0
PUSH=0
BUILD_FROM=0
BUILD_TO=$LAST_STAGE_NUMBER
BUILD_LATEST=1

# Read passed arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --complete)
        COMPLETE=1
        shift # past argument
        shift # past value
        ;;
        --push)
        PUSH=1
        shift # past argument
        shift # past value
        ;;
        -f|--from-stage)
        BUILD_FROM="$2"
        shift # past argument
        shift # past value
        ;;
        -t|--to-stage)
        BUILD_TO="$2"
        BUILD_LATEST=0        
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        echo_help
        exit
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done

# Bound to last stage
if [[ BUILD_TO -gt LAST_STAGE_NUMBER ]]; then
    echo -e "Warning!\nExceeded last stage number with --to-stage $BUILD_TO."\
    " Buonded back to the lastest stage."
    BUILD_TO=$LAST_STAGE_NUMBER
fi

# Handle the complete build case
if ((COMPLETE)); then 
    BUILD_FROM=0
    BUILD_TO=$LAST_STAGE_NUMBER
    BUILD_LATEST=1
fi


STAGE=$BUILD_FROM
while [ $STAGE -le $BUILD_TO ]
do
    echo "

################################################################################
build-helper.sh: building STAGE $REPO:stage-$STAGE
"
    docker build --tag $REPO:stage-$STAGE -f Dockerfile.stage-$STAGE .

    # push
    if ((PUSH)); then 
        docker push $REPO:stage-$STAGE
    fi
    ((STAGE++))
done

# Build latests
if ((BUILD_LATEST)); then 
    echo "

################################################################################
build-helper.sh: building latest stage: $REPO:latest
"
    docker build --tag $REPO:latest -f Dockerfile .
    
    # push
    if ((PUSH)); then 
        docker push $REPO:stage-$STAGE
    fi
fi
