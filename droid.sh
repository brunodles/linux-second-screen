#!/bin/bash

start() {
  shell am start -a android.intent.action.VIEW $1
}

setDate() {
  su date -s $1
}

getIp() {
#  shell ip a
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

screenshot() {
  file=screenshot.png
  shell screencap -p /tmp/screencap.png
  pull /tmp/screencap.png $file
  
  orientation=$(orientation)
  echo "Orientation '$orientation'"
  rotation=$(( $orientation * -90 ))
  echo "Rotation '$rotation'"
  run convert $file -rotate $rotation $file
  xdg-open $file &
}

orientation() {
  orientation=$1
  if [ -z "$orientation" ];then
    orientation=0
    echo $(adb shell dumpsys input | grep 'SurfaceOrientation' | grep -oP "\d+")
    exit 0
  fi
  if [[ $orientation -lt 0 || $orientation -gt 4 ]];then
    orientation=0
    echo "Orientation value is invalid"
    return 1
  fi
  echo "Orientation $orientation"
  shell content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:$orientation
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

dev() {
  touch() {
    show() {
      shell content insert --uri content://settings/system --bind name:s:show_touches --bind value:i:1
    }
    hide() {
      shell content insert --uri content://settings/system --bind name:s:show_touches --bind value:i:0
    }
    $1
  }
  $@
}

resolution() {
  shell dumpsys window | grep Display: | grep -Po "(\d+x\d+)" | head -1
}

# Thanks to MaxChinni https://stackoverflow.com/a/24038245/1622925
input() {
  record() {
    adb shell getevent | grep --line-buffered ^/ | tee /tmp/android-touch-events.log
  }
  playback() {
    awk '{printf "%s %d %d %d\n", substr($1, 1, length($1) -1), strtonum("0x"$2), strtonum("0x"$3), strtonum("0x"$4)}' /tmp/android-touch-events.log | xargs -l echo adb shell sendevent
  }
  $@
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

 orientation [direction]
  - Check or Change device orientation device to direction
    none - withou parameter can check current orientation
    0 - portrait  - top
    1 - landscape - left
    2 - portrait  - bottom
    3 - landscape - righ

 resolution
  - Print device resolution

 input <record|playback>
  - record and playback inputs on device.

 dev <touch>
  - Manage some dev options
  touch <show|hide>
    - manage touch visibility
      e.g: $0 dev touch show
    
TEXT
}

if [ "$(type -t $1)" == "function" ]; then
  $@
else
  help
fi
