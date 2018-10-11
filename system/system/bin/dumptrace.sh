#!/system/bin/sh

MemTotalStr=`cat /proc/meminfo | /system/bin/grep MemTotal`
MemTotal=${MemTotalStr:16:8}
if [ $MemTotal -lt 800000 ]; then
    echo "dumptracer.sh exit becasue MemTotal = $MemTotal"
    exit 0
fi

systracing_is_running=`cat /d/tracing/tracing_on`
if [ "$systracing_is_running" -eq "0" ]; then
    exit 0
fi
echo 500 > /sys/class/timed_output/vibrator/enable
`echo 500 > /sys/class/leds/vibrator/duration`
`echo 1 > /sys/class/leds/vibrator/activate`

local tt=`date +%G%m%d_%H%M%S`
local reason=`getprop debug.systrace.reason`
local trim_reason=${reason/\//\.}
local trace_file_name=systrace.${tt}.${trim_reason}.txt
local file=/cache/logs/logcat/$trace_file_name
#local file=/cache/logs/logcat/trace.${tt}.${trim_reason}.txt
cd /cache/logs/logcat/

#getenforce|grep Enforcing

#if $busybox [ $? -eq 0 ]; then
#    echo "enforceing..."
#cat /d/tracing/trace > $file
#else
#    atrace -c -b 8192 -t 3600000 gfx wm view webview mdss am res app sched freq dalvik input message binder action memreclaim --async_dump -z -o $file
#fi
time=`date "+%T.%N"`
echo "B|0000|***systrace dump timestamp is $time***" > /d/tracing/trace_marker
atrace2 --async_dump -z -o $file

logcat -b events -d > events.txt
logcat -d > mainsystem.txt

echo $trim_reason | grep "watchdog"
if [ $? -eq 0 ]; then
    echo "----------------------------------------" >> dumpsys_log.txt
    echo "        dumpsys activity all" >> dumpsys_log.txt
    echo "----------------------------------------" >> dumpsys_log.txt
    dumpsys -t 30 activity -v all >> dumpsys_log.txt
    echo "----------------------------------------" >> dumpsys_log.txt
    echo "        dumpsys activity service all" >> dumpsys_log.txt
    echo "----------------------------------------" >> dumpsys_log.txt
    dumpsys -t 30 activity service all >> dumpsys_log.txt
    echo "----------------------------------------" >> dumpsys_log.txt
    echo "        dumpsys activity provider all" >> dumpsys_log.txt
    echo "----------------------------------------" >> dumpsys_log.txt
    dumpsys -t 30 activity provider all >> dumpsys_log.txt

    tar zcf $file.tar.gz $trace_file_name events.txt mainsystem.txt dumpsys_log.txt /d/binder
    rm -fr $file events.txt mainsystem.txt dumpsys_log.txt
else
    #tar zcf $file.tar.gz $file events.txt mainsystem.txt
    tar zcf $file.tar.gz $trace_file_name events.txt mainsystem.txt
    rm -fr $file events.txt mainsystem.txt
fi

mkdir /sdcard/systrace/

funi=0
for file in `ls /cache/logs/logcat/systrace.*.gz | sort -nr`
do
funi=`expr $funi + 1`
if [ "$funi" -gt "3" ]; then
  mv $file /sdcard/systrace/
  echo $file
fi
done

funi=0
for file in `ls /sdcard/systrace/systrace.*.gz | sort -nr`
do
funi=`expr $funi + 1`
if [ "$funi" -gt "60" ]; then
  rm -fr $file
  echo $file
fi
done

setprop debug.systrace.reason ""
echo 500 > /sys/class/timed_output/vibrator/enable
`echo 500 > /sys/class/leds/vibrator/duration`
`echo 1 > /sys/class/leds/vibrator/activate`

