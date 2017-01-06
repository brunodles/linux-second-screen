# linux-second-screen
App to use any android device as second monitor on linux.

## How it will work
The app may have multiples MainActivities.   
1. [ ] Push the app using adb   
3. [x] Ask device for it's resolution. (using `adb` or the `app`)   
4. [x] Create a virtual display matching device answer   
5. [x] Start vnc server   
6. [ ] Push host's configurations to device   
7. [ ] Start the app using adb   
We already made some of those things using a simple script.   


# The power of the script
Take a look at the [monitor.sh](https://github.com/Dlimaun/linux-second-screen/blob/master/monitor.sh).   
This script will create the virtual monitor and start x11vnc server for you.   
You only need to pass those parameters, if you want. The parameters could be passed in any order   
* Device resolution using [width]x[height], without bracets. Sample 800x600
* `-v` - VIRTUAL display to be used. Sample v1, v2, v3
* `-left` or `-right  - the position of your device, related to you display
* `-hst` - Subtract status bar size from virtual display
* `-hsb` - Subtract system bar size from virtual display

## Mixing with ADB?
Some Android device return can return the resolution throught command line.   
To use that you will need to enable developer mode on your device. [Check this](http://developer.android.com/tools/help/adb.html#Enabling) to enable.   
To finish you'll need to point your adb location inside the script file.   
With this you don't need to pass any parameters to the script.   
(This is only recomended for developers)


## For those who aren't using a laptop.
In script file, there's a comment on top asking you to select one of those `fisical`.   
So if you are using `VGA` or `HDMI` video output, comment `fisical="LVDS1"` and uncomment your video output.   


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
