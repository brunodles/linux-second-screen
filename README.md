# linux-second-screen
App to use any android device as second monitor on linux.

## How it will work
The app may have multiples MainActivities   
1. Push the app using adb   
3. Ask the app the device resolution   
4. Create a virtual display matching device answer   
5. Start vnc server   
6. Push host's configurations to device   
7. Start the app using adb   

# Until the app's completion, use this tutorial below.

# Tutorial
Change display configurations and connect with vnc.

## Sample Device Configurations
* Notebook Screen		        1366 x 768
* Android Tablet Screen			1280 x 800

## Method 1
Make the current display bigger matching the **sum** of `Notebook Screen` and `Tablet Screen`.   
Enlarge the screen with the result

      xrandr --fb 2646x800
		  
Start VNC Server   
Params `width`x`height`+`startWidth`+`startHeight`.   
The `startWidth` is one pixel after notebook width.

      x11vnc -clip 1280x800+1367+0

Connect with wanted vnc client.

### Clean
Reset display 0.

      xrandr -s 0


# Method 2
Create a virtaul display.   
Run `cvt` with wanted tablet display sizes.

      cvt 1280 800

Use the `cvt` output to create a `mode`

      xrandr --newmode "1280x800_60.00"   83.50  1280 1352 1480 1680  800 803 809 831 -hsync +vsync

Add the mode to a virtual display

      xrandr --addmode VIRTUAL1 1280x800_60.00

Create a Virtual Display

      xrandr --output VIRTUAL1 --mode 1280x800_60.00 --left-of LVDS1

Start VNC Server

      x11vnc -clip 1280x800+0+0

Connect with wanted vnc client.

### Clean

      xrandr --output VIRTUAL1 --off


## To check displays and modes
		xrandr -q



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
