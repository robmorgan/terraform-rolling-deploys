#!/bin/bash
OVPN_DATA="ovpn-data"
ssh -t ubuntu@$(terraform output nat.ip) sudo docker run --volumes-from $OVPN_DATA --rm mb/openvpn ovpn_genconfig -u udp://$(terraform output nat.ip)
ssh -t ubuntu@$(terraform output nat.ip) sudo docker run --volumes-from $OVPN_DATA --rm -it mb/openvpn ovpn_initpki
