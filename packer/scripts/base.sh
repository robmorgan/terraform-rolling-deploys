#!/usr/bin/env bash
set -xe

# update packages
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# install base packages
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y vim curl

# hostname scripts
sudo bash -c 'cat << "EOF" > /opt/update_hostname.sh
#!/bin/bash
name="$(ec2metadata --instance-id 2>/dev/null)"
if [ "$name" != "" ]; then
  echo "writing hostname $name"
  echo -n $name > /etc/hostname
  echo "127.0.0.1 $name localhost" > /etc/hosts
else
  echo "ec2metadata not found"
fi

hostname -b -F /etc/hostname
EOF'

sudo bash -c 'cat << "EOF" > /etc/init/hostname.conf
description     "set system hostname"

start on startup

pre-start script
  bash /opt/update_hostname.sh
end script

task
exec hostname -b -F /etc/hostname
EOF'

sudo chmod 0755 /opt/update_hostname.sh
sudo chmod 0644 /etc/init/hostname.conf
sudo /opt/update_hostname.sh
sudo hostname -b -F /etc/hostname
