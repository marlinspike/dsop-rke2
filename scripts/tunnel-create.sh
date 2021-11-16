#!/bin/bash

# You can't create devices in docker build phase. This script
# opens the device TAP/TUN tunnel when not run as privileged
echo "=== Creating network device" 
sudo mkdir -p /dev/net
ls -alF /dev/net
if [[ -c /dev/net/tun ]]; then
    echo "=== TUN already exists"
else
    echo "=== Creating TUN" 
    sudo mknod /dev/net/tun c 10 200
    ls -alF /dev/net
fi