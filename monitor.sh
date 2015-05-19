#!/bin/bash

## PARAMS
## 1 - VIRTUAL display to be used. Sample VIRTUAL1 or VIRTUAL2
## 2 - Device resolution using [width]x[height], without bracets
## 3 - Position left or right

### Uncomment what you are using, hardcoded
## Laptop
fisical="LVDS1"
## VGA
#fisical="VGA1"
## HDMI
#fisical="HDM1"

## ADB path. hardcoded
adb_bin=~/android-sdk-linux/platform-tools/adb


## Log and Run commands
function run () {
	echo "$1"
	$1
}

## Find Possible IPs
echo "Possible IPs, use 'ifconfig' to check it out, if you want"
ifconfig | grep 'inet addr' | cut -d':' -f 2 | cut -d' ' -f 1
echo ""

## Find Android device Resolution, some devices works
if [ -z "$2" ] ; then
	device=$($adb_bin shell dumpsys window displays | grep init | cut -d'=' -f 2 | cut -d' ' -f 1)
else
	device=$2
fi
if [ -z "$device" ] ; then
	echo "Can't read device resolution using adb"
	exit 0
else
	## Device width and height
	d_width=$(echo $device | cut -d'x' -f 1)
	d_height=$(echo $device | cut -d'x' -f 2)
fi

echo "device  = $device"
echo "width   = $d_width"
echo "height  = $d_height"
echo ""

## Check param position, this position is where the user want the new screen
if [ -z "$3" ] ; then
	position="left"
else
	position=$3
fi
#echo "position= $position"
if [ "$position" = "left" ] ; then
	xinerama="xinerama0"
else
	xinerama="xinerama1"
fi


## Find Host Resolution
host=$(xdpyinfo  | grep 'dimensions:' | cut -d' ' -f 7)
h_width=$(echo $host | cut -d'x' -f 1)
h_height=$(echo $host | cut -d'x' -f 2)

echo "host    = $host"
echo "width   = $h_width"
echo "height  = $h_height"
echo ""


## Proportion, bash don't handle float, only integers so we use bc to do that operation
##proportion=$(($d_height / $h_height))
proportion=$(bc <<< "scale=2; $d_height / $h_height")
v_width=$(bc <<< "scale=0; $d_width / $proportion")
v_height=$h_height
echo "virtual proportion = $proportion"
echo "width   = $v_width"
status_bar=32
system_bar=48
## Remove status bar height
v_height=$(($v_height - $status_bar))
## Remove system bar height
v_height=$(($v_height - $system_bar))
echo "height  = $v_height"
echo ""


## Use VIRTUAL1 if none was passed
if [ -z "$1" ] ; then
	virtual="VIRTUAL1"
else
	virtual=$1
fi
echo "Display = $virtual"


## Build the modeline, the display configurations
modeline=$(cvt $v_width $v_height 20.00 | grep "Modeline" | cut -d' ' -f 2-17)
## Find the mode
mode=$(echo "$modeline" | cut -d' ' -f 1)
## remove quotes, don't need to remove quotes
#mode=${mode//\"}
res=$(echo $mode | cut -d'_' -f 1)
echo "device  = $res"


## Evaluates the start width position, to clip vnc
#s_width=$(echo $host | cut -d'x' -f 1)
#s_width=$((s_width + 1))
#echo "s_width = $s_width"

#echo $modeline
#echo $mode
echo ""


## Create Virtual Display
run "xrandr --newmode $modeline"
run "xrandr --addmode $virtual $mode"
run "xrandr --output $virtual --mode $mode --${position}-of ${fisical}"


## Start VNC
run "x11vnc -clip ${xinerama} -xrandr -ncache 1 -nosel -viewonly -fixscreen \"V=2\" -noprimary -nosetclipboard -noclipboard -cursor arrow -nopw -nowf -nonap -noxdamage -sb 0 -display :0"


## Turn VirtualDisplay off
run "xrandr --output $virtual --off"
run "xrandr --delmode $virtual $mode"
run "xrandr --rmmode $mode"
run "xrandr -s 0"
