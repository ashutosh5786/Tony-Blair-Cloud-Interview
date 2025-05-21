#!/bin/bash

set -e

IMAGE_NAME="ml-serving"
TAG="latest"

echo "🐳 [serving] Building Docker image..."
docker build -t $IMAGE_NAME:$TAG .

read -p "➡️  Do you want to run it locally (port 8000)? (y/n): " run_local
if [[ "$run_local" == "y" ]]; then
  docker run -d -p 8000:80 --name $IMAGE_NAME $IMAGE_NAME:$TAG
  echo "✅ App running on http://localhost:8000"
fi
