#!/system/bin/sh
/system/bin/iotop2 -m 16 -d 30 -P -a -s all -D -n 240
while true
do
sleep 30
pidof iotop2
if [ $? -eq 1 ]; then
/system/bin/iotop2 -m 16 -d 30 -P -a -s all -D -n 240
fi
done

