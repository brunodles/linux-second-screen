#!/bin/bash

# xrandr --newmode "1232x768_20.00"   23.75  1232 1264 1384 1536  768 771 781 784 -hsync +vsync
# xrandr --addmode VIRTUAL1 "1232x768_20.00"
# xrandr --output VIRTUAL1 --mode "1232x768_20.00" --right-of VGA1
# x11vnc -clip xinerama2 -xrandr -ncache 1 -nosel -viewonly -fixscreen "V=2" -noprimary -nosetclipboard -noclipboard -cursor arrow -nopw -nowf -nonap -noxdamage -sb 0 -display :0
# xrandr --output VIRTUAL1 --off
# xrandr --delmode VIRTUAL1 "1232x768_20.00"
# xrandr --rmmode "1232x768_20.00"
# xrandr -s 0

xrandr --newmode "1280x800_20.00"   25.75  1280 1320 1440 1600  800 803 809 812 -hsync +vsync
xrandr --addmode VIRTUAL1 "1280x800_20.00"
xrandr --output VIRTUAL1 --mode "1280x800_20.00" --left-of LVDS1
x11vnc -clip xinerama0 -xrandr -ncache 1 -nosel -viewonly -fixscreen "V=2" -noprimary -nosetclipboard -noclipboard -cursor arrow -nopw -nowf -nonap -noxdamage -sb 0 -display :0
xrandr --output VIRTUAL1 --off
xrandr --delmode VIRTUAL1 "1280x800_20.00"
xrandr --rmmode "1280x800_20.00"
# xrandr -s 0
