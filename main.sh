#!/bin/bash
declare INTEL_FILE="/usr/share/X11/xorg.conf.d/20-intel.conf"

main() {
  case $1 in
    create)
      createDummyDisplay ${@:2}
    ;;
    editIntel)
      editIntel
    ;;
    setRes)
      setRes ${@:2}
    ;;
    *)
      help
    ;;
  esac
}

createDummyDisplay() {
count=$1
  if [ -z "$count" ];then
    count=1
  fi
  if [ "$EUID" -ne 0 ]; then
    echo We may need sudo permissions to write the following file \"$INTEL_FILE\"
    echo
  fi
  sudo tee $INTEL_FILE > /dev/null <<TEXT
Section "Device"
    Identifier "intelgpu0"
    Driver "intel"
    Option "VirtualHeads" "$count"
EndSection
TEXT

 echo -e "Result\033[0;33m"
 cat $INTEL_FILE
 echo -e "\033[0m"
 echo Restart is needed to apply changes.
}

editIntel() {
  sudo vim $INTEL_FILE
}

setRes() {
  virtual=$1
  width=$2
  height=$3
  modeline=$(cvt $width $height 20 | grep "Modeline" | cut -d' ' -f 2-17)
  modeName=$(echo $modeline | cut -d' ' -f 1)
  
  modeline=${modeline//\"}
  modeName=${modeName//\"}

  echo Creating \"$modeName\" on \"$virtual\"
  xrandr --newmode $modeline
  xrandr --addmode $virtual $modeName
  xrandr --output $virtual --mode $modeName --auto
}

help() {
  cat <<TEXT
Virtual Display Helper

Commands
 create <n>
  - creates n virtual displays
    example: $0 create 4

 setRes <display> <width> <height>
  - set resolution for a virtual display
    example: $0 setRes VIRTUAL1 800 600

 help
  - show this message
TEXT
}

main $@
