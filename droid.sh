#!/bin/bash

setDate() {
  su date -s $1
}

getIp() {
#  run "adb shell ip a"
  shell netcfg
}

wifiConnect() {
# TODO: may need to do manually, look https://stackoverflow.com/a/9368211/1622925
  shell am startservice \
    -n com.google.wifisetup/.WifiSetupService \
    -a WifiSetupService.Connect \
    -e ssid $1 \
    -e passphrase $2
}

open() {
  home() {
    shell am start -a android.intent.action.MAIN -c android.intent.category.HOME
  }
  $1
}

su() {
  shell su -c \"$@\" 0
}

shell() {
  run adb shell $@
}

run() {
  echo \>$@
  $@
}

help() {
  cat <<TEXT
Droid Commands
 setDate <date format>
  - change device date using format yyyyMMdd.HHmmss

 getIp
  - Print all IPs for device

 wifiConnect <ssid> <pasword>
  - Connectos to a wifi network
TEXT
}

if [ "$(type -t $1)" == "function" ]; then
  $@
else
  help
fi
