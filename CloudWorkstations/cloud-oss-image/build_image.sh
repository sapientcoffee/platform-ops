#!/usr/bin/env bash

set -eo pipefail

if [ -z $REGISTRY_URL ]; then
    echo "Can't build image: \$REGISTRY_URL not defined"
    exit 1
fi

if [ -z $IMAGE_NAME ]; then
    echo "Can't build image: \$IMAGE_NAME not defined"
    exit 1
fi

if [ -z $WORKSPACE_DIR ]; then
    WORKSPACE_DIR="/tmp"
else
    WORKSPACE_DIR="/workspace"
fi

OUTFILE="$WORKSPACE_DIR/data.txt"

SUFFIX=$(date +%Y%m%d%H%M%S)
IMAGE_URL="$REGISTRY_URL/$IMAGE_NAME:$SUFFIX"

docker build . -t "$IMAGE_URL"
docker push "$IMAGE_URL"

echo "Image built successfully: $IMAGE_URL"

echo "$IMAGE_URL" > "$OUTFILE"
echo "Outfile $OUTFILE written"