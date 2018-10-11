#!/system/bin/sh

function start_persist_atrace()
{
#    supolicy --live "allow tracer system_file:file entrypoint;"
    /system/bin/atrace2 -c -b 4096 -t3600000 gfx wm view webview mdss am res app sched freq dalvik input binder action memreclaim mmc disk --async_start
}


if [ "x$(getprop persist.sys.ztelog.enable)" != "x1" ]; then
    exit 0
fi

################################################################
# Don't enable systrace when the total memory is below 800MB
MemTotalStr=`cat /proc/meminfo | /system/bin/grep MemTotal`
MemTotal=${MemTotalStr:16:8}
echo "MemTotal==$MemTotal"
if [ $MemTotal -lt 800000 ]; then
    echo "start_tracer.sh exit becasue MemTotal = $MemTotal"
    exit 0
fi

echo 4096 > /d/tracing/saved_cmdlines_size

local getsystrace=`getprop init.svc.getsystrace`
local systracing_is_running=`cat /d/tracing/tracing_on`
if [ "$getsystrace" != "running" ]; then
    if [ "$systracing_is_running" -eq "0" ]; then
        setprop sys.check.interval 500
        start_persist_atrace
        exit 0
    fi
fi


local tt=`date +%G%m%d_%H%M%S`

