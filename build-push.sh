#!/bin/bash

# This script builds, tags, and pushes the teaching Docker image to both DockerHub
# and GitHub Container Registry (GHCR).
#
# Usage:
#   ./build-push.sh --version <version>
#
# Arguments:
#   --version       The version tag for the image (required)
#                   Example: ./build-push.sh --version 1.0.0
#
# The script will:
#   1. Build the image using the Dockerfile
#   2. Tag the image with both :latest and :<version> tags
#   3. Push all tags to both DockerHub and GHCR
#
# Requirements:
#   - Docker must be installed and running
#   - User must be logged in to both DockerHub and GHCR
#   - Appropriate permissions for pushing to both registries

# Initialize variables
VERSION=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: ./build-push.sh --version <version>"
      exit 1
      ;;
  esac
done

# Check for required arguments
if [ -z "$VERSION" ]; then
  echo "Error: --version argument required. Usage: ./build-push.sh --version <version> --organization <organization>"
  exit 1
fi

IMAGE_NAME=teaching
FULL_IMAGE_NAME=ghcr.io/jnoelvictorino/$IMAGE_NAME

echo "Building image..."
docker build -t $FULL_IMAGE_NAME:latest \
  --label "org.opencontainers.image.version=$VERSION" \
  --label "org.opencontainers.image.created=$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  .

echo "Tagging..."
docker tag $FULL_IMAGE_NAME:latest $FULL_IMAGE_NAME:$VERSION
docker tag $FULL_IMAGE_NAME:latest $FULL_IMAGE_NAME:latest
docker tag $FULL_IMAGE_NAME:latest $FULL_IMAGE_NAME:$VERSION

echo "Pushing..."
docker push $FULL_IMAGE_NAME:$VERSION
docker push $FULL_IMAGE_NAME:latest