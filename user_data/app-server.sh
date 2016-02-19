#!/bin/bash
bash 2>&1 <<"USERDATA" | while read line; do echo "$(date --iso-8601=ns) $line"; done | tee -a /var/log/userdata.log
set -xe

# Hostname
/opt/update_hostname.sh
hostname -b -F /etc/hostname

# Run Nginx
sudo docker run -d -p 80:80 nginx
USERDATA
