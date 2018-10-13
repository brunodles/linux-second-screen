#!/bin/bash

start() {
  shell am start -a android.intent.action.VIEW $1
}

setDate() {
  su date -s $1
}

getIp() {
#  run "adb shell ip a"
  shell netcfg
}

getSdk() {
  shell getprop ro.build.version.sdk
}

wifiConnect() {
#  echo "Use one of following:"
#  echo " wifiConnect_service"
#  echo " wifiConnect_file"
#  #wifiConnect_service
  wifiConnect_file
}

wifiConnect_service() {
  shell am startservice \
    -n com.google.wifisetup/.WifiSetupService \
    -a WifiSetupService.Connect \
    -e ssid $1 \
    -e passphrase $2
}

wifiConnect_file() {
  echo "Wanted ssid"
  read -e ssid
  echo "Password:"
  read -es pass
  echo "Password manager <WPA-PSK>"
  read -e mgmt
  if [ -z "$mgmt" ]; then
    mgmt="WPA-PSK"
  fi

  { # try
    pull /data/misc/wifi/wpa_supplicant.conf .wifi 
  } || {
    cat >.wifi<<TEXT
ctrl_interface=tiwlan0
update_config=1
device_type=0-00000000-0
TEXT
  }
  cat >>.wifi<<TEXT
network={
  ssid="$ssid"
  psk="$pass"
  key_mgmt=$mgmt
  priority=1
}
TEXT
  push .wifi /data/misc/wifi/wpa_supplicant.conf
  run adb shell chown system.wifi /data/misc/wifi/wpa_supplicant.conf
  run adb shell chmod 660 /data/misc/wifi/wpa_supplicant.conf
  run adb shell am start -a android.intent.action.MAIN -n com.android.settings/.Settings
}

screenShot() {
  file=screenshot.png
  shell screencap -p /tmp/screencap.png
  pull /tmp/screencap.png $file
  
  orientation=$(adb shell dumpsys input | grep 'SurfaceOrientation' | grep -oP "\d+")
  echo "Orientation '$orientation'"
  rotation=$(( $orientation * -90 ))
  echo "Rotation '$rotation'"
  run convert $file -rotate $rotation $file
  xdg-open $file
}


open() {
  home() {
    shell am start -a android.intent.action.MAIN -c android.intent.category.HOME
  }
  settings() {
    shell am start -a android.intent.action.MAIN -n com.android.settings/.Settings
  }
  date() {
    shell am start -a android.provider.Settings.ACTION_DATE_SETTINGS
    shell am start -n com.android.settings/.DateTimeSettings
  }
  $1
}

su() {
  shell su -c \"$@\" 0
}

shell() {
  run adb shell $@
}

pull() {
  run adb pull $@
}

push() {
  run adb push $@
}

run() {
  echo \>$@
  $@
}

help() {
  cat <<TEXT
Droid Commands

 start <uri>
  - start default app that may resolve the requested uri
 
 setDate <date format>
  - change device date using format yyyyMMdd.HHmmss

 getIp
  - Print all IPs for device

 wifiConnect <ssid> <pasword>
  - Connectos to a wifi network

 screenshot
  - Take a screenshot from device.
TEXT
}

if [ "$(type -t $1)" == "function" ]; then
  $@
else
  help
fi
