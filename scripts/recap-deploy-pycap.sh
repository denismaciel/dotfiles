#!/usr/bin/env bash

# Set variables
REPO="recap-technologies/core"
DATE=$(date +'%Y-%m-%d')
TIMESTAMP=$(date +%s)
TAG_PREFIX="pycap-v${DATE}.auto"

NEW_TAG="${TAG_PREFIX}.${TIMESTAMP}"

# Check if tag already exists locally
if git tag -l | grep -q "^${NEW_TAG}$"; then
    echo "Tag $NEW_TAG already exists locally. Skipping creation."
else
    git tag $NEW_TAG
    git push origin $NEW_TAG
    echo "Created and pushed tag: $NEW_TAG"
fi

echo "This will trigger the pycap-prod workflow for deployment."
