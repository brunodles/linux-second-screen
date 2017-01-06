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
This will turn display off, delete the mode from virtual display and then remove the mode.

		xrandr --output VIRTUAL1 --off
		xrandr --delmode VIRTUAL1 "1280x800_60.00"
		xrandr --rmmode "1280x800_60.00"


## To check displays and modes
		xrandr -q
