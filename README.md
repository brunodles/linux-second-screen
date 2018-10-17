# linux-second-screen
Scripts to repurpose old android device as second monitor on linux

## Usage
This repo have many bash scripts to interact with android using adb.
Each script have it's own function.

### Device
A simple wrapper to select target device by name.

#### Add device
```
device add droid2 015F13B817021010
```

#### Usage
```
device droid2 adb shell
device droid2 <any other command>
```

### Display
Change host (linux) display settings.
With this script we can create, change settings or remove of virtual displays.
It does not care about positioning the virtual displays, this should be done using your favorite monitor app. E.g.: xrandr, arandr or some other you like.

### droid
General commands for android.
This script is a wrapper for adb, with it we can:
* start an app to resolve one url
* open pre-defined activites
* set date and time
* get device ip
* connect to wifi
* get sdk
* get model
* get and change orientation
* change some developer settings 
* get screen resolution
* shutdown device
* record and playback inputs

### input
An reimplementation of input script on android.
Some devices doesn't have tap and swipe command, so this script tries to reprotuce theses commands.

### keyboard
Send multiple KEY_EVENTS in a single string.
The idea here is to simplify the way to send keyboard inputs.
This script replaces ` `(space character) by `%s` the one is used by key event.
Also send key events by name, just using UPPERCASED text.
```
# We can input text, then key, the text again, the order doesn't matter
keyboard "My name is Bruno;ENTER;This one is probably on the next field"

# we can also send multiple key events
keyboard "UP;UP;DOWN;DOWN;LEFT;RIGHT;LEFT;RIGHT"
```

### terminal
This script is a wrapper to interact with **screen**, a screen manager for terminal.
Using screen we can share a terminal session like. 
The idea is use it like a vnc, and connect other devices to keep a terminal session running on then like server logs or status.

### vnc
A wrapper for vnc commands.
We have only two commands here:
* Start - wich starts vnc for a virtual display
* window - wich starts vnc for a given window

## Setup
First we need to run setup to install all tools we need to run this.
There are tools that we doesn't provide, like adb (Android Debug Bridge), it comes with android sdk.
You will have to setup adb into your path.
* [adb only](https://developer.android.com/studio/releases/platform-tools)
* [about adb](https://developer.android.com/studio/command-line/adb?hl=pt-br)
* [android sdk](https://developer.android.com/studio/install?hl=pt-br)

Then run setup.
You will be prompt to put your password to install necessary tools.
*We may split setup into multiple phases later, for optional instalation.*
```
# install tools
./main setup

# create virtual displays, only works with intel's graphic card
# you may change 2 by any number of virtual displays you want
./display create 2
```
Restart you computer, if you created virtual display.
When you login again you will see `VIRTUAL` as possible video output.

## How to create a extended display? - Intel's graphic card only
With these scripts it gets simple.
But we still need to make some touches to make then integrated. 
*may I make this on main.*

I high recomend you to write a script to start your own devices, this will make your life a lot easier.
So I will write the step-by-step in a script-like.

### Step 1 - get information from your device
We need to know the resolution from our device, it's orientation and screen size inches.
Based on these two informations we can create one virtual display.

```
# resolution - this one may fail, so you may have to get this information from internet
# ./droid resolution
resolution=$(./droid resolution)

# replace resolution ´x´ by ´ ´ (space)
resolution=${resolution/x/ }

# orientation
# ./droid orientation
orientation=$(./droid orientation)

# inches - this one may fail too, cause we need resolution and density to calculate an aproximate screen inches
# ./droid inches
inches=$(./droid inches)
```

### Step 2 - calculate virtual display resolution
Now we have the resolution let's calculate an virtual display size

```
# ./display calcRes $resolution $inches
virtual=$(./display calcRes $resolution $inches | grep virtual | grep -Po "(\d+x\d+)")
```

### Step 3 - set virtual display resolution
Let's set the resolution for display 1.
Depending on orientation we change order of width and height.
```
virtual=(${virtual/x/ })
width=${virtual[0]}
height=${virtual[1]}
if [ "$orientation" == 0 ] || [ "$orientation" == 2]; then
  # portrait
  ./display setRes 1 $width $height
else
  # landscape
  ./display setRes 1 $height $width
fi
```

### Step 4 - share display on vnc
```
./vnc start 1
```

### Step 5 - share vnc connection directly to device
```
./droid start vnc://{your local ip address}:5900
```
Here we can also use `adb reverse tcp:5900 tcp:5900` to make a tunnel using usb cable, but it only works on android 5.0+.

### Step 6 - clean
Shutdown display and remove configurations from it.
```
./display remove 1
```  

## if you still want to do it by hand
Follow this [tutorial](https://github.com/Dlimaun/linux-second-screen/blob/master/tutorial.md).   


# Similar apps
~~This app will be made by the rage because we have a lot of apps for all other platforms
Only linux isn't supported by those apps.~~   
* [AirDisplay](https://avatron.com/applications/air-display/)
* [AirDisplay Android](https://play.google.com/store/apps/details?id=com.avatron.airdisplay)
* [Splashtop](http://www.splashtop.com/downloads)*
* [Splashtop Extended Display Android](https://play.google.com/store/apps/details?id=com.splashtop.remote.xdisplay)
* [iDisplay Android](https://play.google.com/store/apps/details?id=com.idisplay.virtualscreen)
* [DuetDisplay](http://www.duetdisplay.com/)


Splashtop appear to have a beta, for linux.   
\o/
