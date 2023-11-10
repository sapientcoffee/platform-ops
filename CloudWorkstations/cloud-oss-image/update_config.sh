#!/usr/bin/env bash

set -eo pipefail

if [ -z $WORKSTATIONS_CONFIG_NAME ]; then
    echo "Can't update Workstations config: \$WORKSTATIONS_CONFIG_NAME not defined"
    exit 1
fi

if [ -z $WORKSPACE_DIR ]; then
    WORKSPACE_DIR="/tmp"
else
    WORKSPACE_DIR="/workspace"
fi

IMAGE_URL=$(cat "$WORKSPACE_DIR/data.txt")

echo "Updating Cloud Workstations config with image URL $IMAGE_URL"

# Directly using the Workstations API as the CLI does not yet support this
# operation.
curl -X PATCH \
    "https://workstations.googleapis.com/v1beta/$WORKSTATIONS_CONFIG_NAME?updateMask=container.image" \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    -d "{\"container\": {\"image\": \"$IMAGE_URL\"}}"

echo "Cloud Workstations config updated"