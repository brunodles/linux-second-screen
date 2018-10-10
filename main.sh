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
    calcRes)
      calcRes ${@:2}
    ;;
    startVnc)
      startVnc ${@:2}
    ;;
    setup)
      setup
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

calcRes() {
  v_width=$1
  v_height=$2
  v_inches=$3

  f_xrandr=$(xrandr | grep primary)
  f_res=$(echo $f_xrandr | cut -d' ' -f 4)
  f_res=(${f_res//[+x]/ })
  f_dimens=$(echo $f_xrandr | cut -d' ' -f 13,15)
  f_dimens=(${f_dimens//m/})
  
  f_width=${f_res[0]}
  f_height=${f_res[1]}
  f_inches=$(bc <<< "scale=2; sqrt( ${f_dimens[0]}^2 + ${f_dimens[1]}^2 ) * 0.0393701")

  proportion=$(bc <<< "scale=4; $v_inches / $f_inches")

  r_width=$(bc <<< "scale=0; $v_width * $proportion")
  r_height=$(bc <<< "scale=0; $v_height * $proportion")

  echo Proportion $proportion
  echo "        Width x Height Inches"
  echo "fisical  $f_width x $f_height $f_inches"
  echo "virtual  $v_width x $v_height $v_inches"
  echo "----------------------------"
  echo " result  $r_width x $r_height"

}

startVnc() {
  x11vnc -display :0 -clip xinerama$1 -forever -scale 1:nb -xrandr
}

setup() {
  # x11vnc 		- vnc server used to bind to part o xServer
  # bc 			- bash calculator, as we can't do some operations with default bash
  # screen 		- terminal used to share session, like vnc but with terminal
  # openssh-server 	- secure shell, a tool to connect to terminal remotely
  sudo apt-get install x11vnc bc screen openssh-server
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

 calcRes <width> <heigh> <inches>
  - calculate possible resolutions for a device.
    As devices may have same or  even greater resolutions compared to a normal display, de idea is to use a lower resolution for this device. This leads to a better visualization and performance.

 startVnc <xinerama>
  - start vnc for given display

 setup
  - install necessary tools

 help
  - show this message
TEXT
}

main $@