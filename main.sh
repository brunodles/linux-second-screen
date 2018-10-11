#!/bin/bash
declare INTEL_FILE="/usr/share/X11/xorg.conf.d/20-intel.conf"
declare XORG_FILE="/usr/share/X11/xorg.conf.d/01-dummy-monitor.conf"

main() {
  case $1 in
    create)
      createDummyDisplayIntel ${@:2}
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
    ssh)
      ssh ${@:2}
    ;;
    setup)
      setup
    ;;
    *)
      help
    ;;
  esac
}

createDummyDisplayXorg() {
  count=$1
  if [ -z "$count" ];then
    count=1
  fi
  if [ "$EUID" -ne 0 ]; then
    echo We may need sudo permissions to write the following file \"$XORG_FILE\"
    echo
  fi
  sudo tee $XORG_FILE > /dev/null <<TEXT
Section "Device"
    Identifier  "Configured Video Device"
    Driver      "dummy"
EndSection

Section "Monitor"
    Identifier  "Configured Monitor"
    HorizSync 31.5-48.5
    VertRefresh 50-70
EndSection

Section "Screen"
    Identifier  "Default Screen"
    Monitor     "Configured Monitor"
    Device      "Configured Video Device"
    DefaultDepth 24
    SubSection "Display"
    Depth 24
    Modes "1024x800"
    EndSubSection
EndSection
TEXT

 echo -e "Result\033[0;33m"
 cat $XORG_FILE
 echo -e "\033[0m"
 echo Restart is needed to apply changes.
}

createDummyDisplayIntel() {
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
  w_width=$1
  w_height=$2
  w_inches=$3

  f_xrandr=$(xrandr | grep primary)
  f_res=$(echo $f_xrandr | cut -d' ' -f 4)
  f_res=(${f_res//[+x]/ })
  f_dimens=$(echo $f_xrandr | cut -d' ' -f 13,15)
  f_dimens=(${f_dimens//m/})
  
  f_width=${f_res[0]}
  f_height=${f_res[1]}
  f_inches=$(bc <<< "scale=2; (sqrt( ${f_dimens[0]}^2 + ${f_dimens[1]}^2 ) * 0.0393701)/1")

  proportion=$(bc <<< "scale=4; $w_inches / $f_inches")

  v_width=$(bc <<< "scale=0; ($w_width * $proportion)/1")
  v_height=$(bc <<< "scale=0; ($w_height * $proportion)/1")

  rv_vert_width=$f_width
  rv_vert_height=$(bc <<< "scale=0; ($f_height + $v_height)/1")

  rv_hori_width=$(bc <<< "scale=0; ($f_width + $v_width)/1")
  rv_hori_height=$f_height

  echo Proportion $proportion
  echo "           Width x Height Inches"
  echo "   fisical  $f_width x $f_height $f_inches"
  echo "    wanted  $w_width x $w_height $w_inches"
  echo "----------------------------  Virtual"
  echo "   virtual  $v_width x $v_height"
  echo "----------------------------  Resize + virtual"
  echo "  vertical  $rv_vert_width x $rv_vert_height"
  echo "horizontal  $rv_hori_width x $rv_hori_height"
}

startVnc() {
  x11vnc -display :0 -clip xinerama$1 -forever -xrandr -shared -repeat -noxdamage ${@:2}
}

ssh() {
  if [ "$1" == "setup" ]; then
    mkdir .ssh
    ssh-keygen -t rsa -f ./.ssh/ssh_host_rsa_key
    ssh-keygen -t ecdsa -f ./.ssh/ssh_host_ecdsa_key
    ssh-keygen -t ed25519 -f ./.ssh/ssh_host_ed25519_key
  else
    sudo service ssh $1
  fi
  # it won't be so easy, we may need to start a new ssh server with custom settings.
  # To do so, we need to create ssh keys for our server, since we can't point to user ones.
  # /usr/sbin/sshd -p 22200 
}

setup() {
  # x11vnc 		- vnc server used to bind to part o xServer
  # bc 			- bash calculator, as we can't do some operations with default bash
  # screen 		- terminal used to share session, like vnc but with terminal
  # openssh-server 	- secure shell, a tool to connect to terminal remotely
  sudo apt-get install x11vnc bc screen openssh-server xserver-xorg-video-dummy
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

 startVnc <xinerama> <x11vnc commands>
  - start vnc for given display
    example: $0 startVnc 1 -scale 1/2:nb -ncache 0
      This will start vnc using scale 1/2 wihout bleeding and 0 cache

 ssh <start|stop|restart>
  - command ssh server, just a wrapper to start, stop or restart the ssh server daemon.
    This will be needed to run screen commands

 screenStart <name> [commands [args]]
  - start a new screen with given name. This will allow others to connect to the same terminal, it's like a shared terminal.

 screenList
  - list shared screens.

 screenConnect <name>
  - connect o a screen with given name

 setup
  - install necessary tools

 help
  - show this message
TEXT
}

main $@
