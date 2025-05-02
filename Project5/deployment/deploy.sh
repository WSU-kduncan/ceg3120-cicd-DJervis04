#!/bin/bash

CONTAINER_NAME="angular-app"
IMAGE_NAME="wsudjervis/jervis-ceg3120:latest"

# Stop and remove the existing container
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

# Pull the latest image
docker pull $IMAGE_NAME

# Run a new container
docker run -d --name $CONTAINER_NAME -p 4200:4200 $IMAGE_NAME

