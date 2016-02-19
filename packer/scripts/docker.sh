#!/usr/bin/env bash
set -xe

# install Docker
curl -fsSL https://get.docker.com/ | sudo sh

# install Docker Compose
sudo sh -c 'curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose'
sudo chmod +x /usr/local/bin/docker-compose
