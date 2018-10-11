#!/system/bin/sh
#this .sh is used to test current while devices enter LPM in FTM

#how to run this .sh
#adb push ftmlpm.sh /data/
#adb shell
#cd /data
#chmod 777 ftmlpm.sh
#./ftmlpm.sh

target=`getprop sys.zftdoctor_completed`

if [ -f "/sys/class/backlight/panel0-backlight/brightness" ];then
    while [ "$target" != "1" ] ;do
        sleep 1
        target=`getprop sys.zftdoctor_completed`
    done

    echo 0 > /sys/class/power_supply/battery/charging_enabled
    sleep 1
    input keyevent POWER
else
    echo 0 > /sys/class/leds/lcd-backlight/brightness
    echo 4 > /sys/class/graphics/fb0/blank
fi

echo mmi > /sys/power/wake_unlock
echo PowerManagerService.Display > /sys/power/wake_unlock
echo PowerManagerService.WakeLocks > /sys/power/wake_unlock
echo mem > /sys/power/autosleep


