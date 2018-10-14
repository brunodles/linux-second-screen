#!/bin/bash
CONFIG_FILE=".input.config"
KEY_X=53
KEY_Y=54
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
  sendevent $INPUT 3 $KEY_X $1
  sendevent $INPUT 3 $KEY_Y $2
  execute
}

# Send a command to execute event
# Also if no command was sent it will clean inputs
execute() {
  sendevent $INPUT 0 2 0
  sendevent $INPUT 0 0 0
}

sendevent() {
#  echo adb shell sendevent $@
  adb shell sendevent $@
}

# declare touch down?
#sendevent $event 3 48 1

# ???
#sendevent $event 3 52 0
#sendevent $event 3 57 0

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
