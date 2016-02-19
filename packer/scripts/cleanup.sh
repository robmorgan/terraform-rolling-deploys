#!/usr/bin/env bash
set -xe

echo Cleaning up...
sudo apt-get -y autoremove
sudo apt-get -y clean

sudo rm -rf /tmp/*
sudo rm -rf /ops
