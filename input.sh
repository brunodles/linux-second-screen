#!/bin/bash
CONFIG_FILE=".input.config"

KEY_X=53
KEY_Y=54
MIN_X=20
MAX_X=1004
MIN_Y=0
MAX_Y=960

declare INPUT
DOC=""
declare ORIENTATION

DOC+="
  findInput <input type>
    - Find event input by type
      know types:
        lm3530_led
        proximity
        sholes-keypad
        qtouch-touchscreen
        cpcap-key
        accelerometer
        compass
"
findInput() {
  timeout 1 adb shell getevent > /tmp/inputs
  cat /tmp/inputs | grep -B 1 "$1" | grep -Po "/dev/input/event(\d+)"
}

DOC+="
  updateConfig
    - Update config file, needed after device change
"
updateConfig() { 
  INPUT=$(findInput "touch")
  echo "INPUT=$INPUT">$CONFIG_FILE
}
if [ -f $CONFIG_FILE ]; then
  . $CONFIG_FILE
fi
if [ -z "$INPUT" ]; then
  updateConfig
fi

DOC+="
  tap <x> <y>
    - send tap event on position
"
tap() {
  touch $1 $2
  execute
}

DOC+="
  swipe <x1> <y1> <x2> <y2>
    - send swipe event
"
swipe() {
  touch $1 $2
  touch $3 $4
  execute
}

DOC+="
  touch <x> <y>
    - send touch event. This one keeps touch pressed.
"
touch() {
  if [ -z "$ORIENTATION" ]; then
    ORIENTATION=$(orientation)
  fi
  case $ORIENTATION in
    0)
      x=$(( $MIN_X + $1 ))
      y=$(( $MIN_Y + $2 ))
    ;;
    1)
      x=$(( $MAX_X - $2 - 10 ))
      y=$(( $1 - 20 ))
    ;;
    2)
      x=$(( $MAX_X - $1 ))
      y=$(( $MAX_Y - $2 ))
    ;;
    3)
      x=$1
      y=$(( $MAX_Y - $2 - 10 ))
    ;;
    *)
      x=$1
      y=$2
    ;;
  esac
  sendevent $INPUT 3 $KEY_X $x
  sendevent $INPUT 3 $KEY_Y $y
  execute
}

# Send a command to execute event
# Also if no command was sent it will clean inputs
execute() {
  sendevent $INPUT 0 2 0
  sendevent $INPUT 0 0 0
}

# Send event to android device
sendevent() {
  echo adb shell sendevent $@
  adb shell sendevent $@
}

# get current orientation
orientation() {
#  echo $(adb shell dumpsys input | grep 'SurfaceOrientation' | grep -oP "\d+")
  echo $(./droid.sh orientation)
}

help() {
  cat <<TEXT
Send input to device, simulating input program inside android

usage:  $0 <command>
        $0 tap <x> <y>
        $0 swipe <x1> <y1> <x2> <y2>

Other commands:
$DOC
TEXT
}

if [ "$(type -t $1)" == "function" ]; then
  $@
else
  help
fi
