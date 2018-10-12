#!/bin/bash

main() {
  case $1 in
    start)
      start ${@:2}
    ;;
    window)
      window ${@:2}
    ;;
    setup)
      setup
    ;;
    *)
      help
    ;;
  esac
}

start() {
  x11vnc -display :0 -clip xinerama$1 -forever -xrandr -shared -repeat -noxdamage ${@:2}
}

window() {
  echo Click on wanted window to start vnc
  winId=$(xwininfo | grep -Eio "Window id: (0x\w+)" | cut -d' ' -f3)
  title=$(xprop -id $winId | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2)
  echo Window id $winId - \"$title\"
  x11vnc -forever -shared -repeat -noxdamage -id $winId $@
}

setup() {
  sudo apt-get -y install x11vnc
}

help() {
  cat <<TEXT
Vnc wrapper

Commands:
 start <command> [args]
  - start vnc for given display
    example: $0 startVnc 1 -scale 1/2:nb -ncache 0
      This will start vnc using scale 1/2 wihout bleeding and 0 cache

 window [x11vnc commands]
  - start vnc for a window, you will need to click on desired window

TEXT
}

main $@
