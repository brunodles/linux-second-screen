#!/bin/bash
echo "Install x11vnc"
sudo apt-get install x11vnc

echo "Create Virtual displays"
cat >> /usr/share/X11/xorg.conf.d/20-intel.conf <<TEXT
Section "Device"
    Identifier "intelgpu0"
    Driver "intel"
    Option "VirtualHeads" "2"
EndSection
TEXT
