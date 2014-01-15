#!/bin/bash -x
VERSION=$(lsb_release -cs)

# Sources
	echo "
deb http://ftp.de.debian.org/debian/ $VERSION main contrib non-free
deb-src http://ftp.de.debian.org/debian/ $VERSION main contrib non-free
deb http://security.debian.org/ $VERSION/updates main contrib non-free
deb-src http://security.debian.org/ $VERSION/updates main contrib non-free
deb http://ftp.de.debian.org/debian/ $VERSION-updates main
deb-src http://ftp.de.debian.org/debian/ $VERSION-updates main
" > /etc/apt/sources.list

# Chrome

	read -p "Google Chrome installieren? [y/N]" GOOGLE
	if [ $GOOGLE = y ]
		then 
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
		dpkg -i /tmp/chrome.deb
		rm /tmmp/chrome.deb
	fi

# Trackpoint (https://wiki.debian.org/InstallingDebianOn/Thinkpad/Trackpoint)
	echo "
Section "InputClass"
    Identifier      "Trackpoint"
    MatchProduct    "TrackPoint|DualPoint Stick"
    MatchDevicePath "/dev/input/event*"
    Option          "EmulateWheel" "true"
    Option          "EmulateWheelButton" "2"
    Option          "EmulateWheelTimeout" "200" 
    Option          "YAxisMapping" "4 5" # vertikales Scrollen
    Option          "XAxisMapping" "6 7" # horizontales Scrollen
EndSection
" > /usr/share/X11/xorg.conf.d/20-trackpoint.conf

	echo "
Section "InputClass"
        Identifier "touchpad"
        MatchProduct "SynPS/2 Synaptics TouchPad"
        Driver "synaptics"
        Option "MinSpeed" "1"
        Option "MaxSpeed" "1"
        Option "AccelerationProfile" "2"
        Option "AdaptiveDeceleration" "1000"
        Option "ConstantDeceleration" "16"
        Option "VelocityScale" "30"
        Option "AccelerationNumerator" "30"
        Option "AccelerationDenominator" "10"
        Option "AccelerationThreshold" "10"
EndSection
" > /usr/share/X11/xorg.conf.d/50-touchpad.conf

# Thinkfan (http://www.thinkwiki.org/wiki/ACPI_fan_control_script)
	apt-get install thinkfan
	echo "options thinkpad_acpi fan_control=1"|tee /etc/modprobe.d/thinkfan.conf
	modprobe -rv thinkpad_acpi
	modprobe -v thinkpad_acpi
	echo "
START=yes
DAEMON_ARGS="-q -b 1 -s 3"
"
# > /etc/default/thinkfan
	/etc/init.d/thinkfan start

# rc.local
	echo "
echo 0 > /sys/devices/platform/thinkpad_acpi/bluetooth_enable
xset -dpms
exit 0
" > /etc/rc.local

# xrandr
	apt-get install x11-xserver-utils
	echo "
#!/bin/bash
xset -dpms
MON1="LVDS1"
MON2="VGA1"
MON3="DP3"
if	[ $(xrandr --query | grep -c "$MON1 connected") = 1 ] &&
	[ $(xrandr --query | grep -c "$MON2 connected") = 1 ]
then	xrandr --output $MON2 --right-of $MON1 --output $MON1 --auto;
elif	[ $(xrandr --query | grep -c "$MON1 connected") = 1 ] &&
	[ $(xrandr --query | grep -c "$MON3 connected") = 1 ]
then	xrandr --output $MON3 --right-of $MON1 --auto --output $MON1 --auto;
elif 	[ $(xrandr --query | grep -c "$MON2 connected") = 1 ] &&
	[ $(xrandr --query | grep -c "$MON3 connected") = 1 ]
then	xrandr --output $MON1 --off && xrandr --output $MON3 --right-of $MON2 --auto --output $MON3 --auto;
else	xrandr --output $MON2 --off --output $MON3 --off --output $MON1 --auto;
	sudo ifscheme SuperNintento >> /dev/null; sudo ifup wlan0 >> /dev/null
fi
" > /usr/bin/monitor-hotkey

# i3wm
	apt-get install i3 i3lock i3status i3-wm i3-wm-dbg
	read -p "User?" $ENDUSER
	mkdir -p /home/$ENDUSER/.i3/images/
	i3PATH="/home/$ENDUSER/.i3"
	wget setup.so/.i3/config -O $i3PATH
	wget setup.so/.i3/i3status -O $i3PATH
	wget setup.so/.i3/images/debian.png -O $i3PATH/images

# .bashrc
	wget setup.so/.bashrc -O /home/$ENDUSER/
	touch /home/$ENDUSER/.hushlogin
# vimrc
	echo "
syntax on
set number
set wrap
set tabstop=4
" > /home/$ENDUSER/.vimrc

# ...
	apt-get install sshfs seahorse gdebi cups cups-client cups-pdf cups-driver-gutenprint hplip hplip-gui mtr-tiny unrar-nonfree burn iftop git sl irssi mcabber cmus mutt-patched notmuch-mutt offlineimap xbmc mplayer murrine-themes gtk-chtheme feh evince scrot terminator xbacklight 

echo -e "\n\nrestlichen configs vom letzten install einbauen.."
