#!/bin/bash

setDate() {
  command="adb shell su -c \"date -s $1\" 0"
  echo $command
  $command
}

help() {
  cat <<TEXT
Droid Commands
 setDate <date format>
  - change device date using format yyyyMMdd.HHmmss
TEXT
}

case $1 in
  setDate)
    $1 ${@:2}
  ;;
  *)
    help
  ;;
esac
#echo $(type -t $1)
