#!/usr/bin/env bash

# Download the installation script
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose


# Apply executable permissions to the binar
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# Test the installation
docker compose version
