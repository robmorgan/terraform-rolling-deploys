#!/bin/bash
OVPN_DATA="ovpn-data"
ssh -t ubuntu@$(terraform output nat.ip) sudo docker run --volumes-from $OVPN_DATA -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn
