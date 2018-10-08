#!/bin/bash
OVPN_DATA="ovpn-data"
ssh -t ubuntu@$(terraform output nat.ip) sudo docker run --volumes-from $OVPN_DATA --rm mb/openvpn ovpn_getclient "${1}" > "${1}.ovpn"
