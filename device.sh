#!/bin/bash
CONFIG_FILE=".device.config"

if [ -f "$CONFIG_FILE" ]; then
  source $CONFIG_FILE
fi

case $1 in
  "")
    echo Selected device \"$ANDROID_SERIAL\"
    exit 0
  ;;
  add)
    echo "$2=$3">>$CONFIG_FILE
  ;;
  *h|*help)
    cat <<TEXT
Device helper
  A simple wrapper to dive devices alias

usage:
  $0 add <alias> <serial>
    - Add device to a alias list

  $0 <alias> <command>
    - run command on given device

  $0 h
  $0 help
    - Show this message
TEXT
  ;;
  *)
    ANDROID_SERIAL=$(eval echo \$$1)
    echo Serial \"$ANDROID_SERIAL\"
    ${@:2}
esac
