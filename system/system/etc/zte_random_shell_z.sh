#!/system/bin/sh
######################
# Copyright (C) 2011 by ZTE
#####################
#edit this file for random 
#zhangji edit 
# 

data_file=1
mkdir /sdcard/SecurityCall/RandomData
while true
do

dd if=/dev/random of=/storage/emulated/0/SecurityCall/RandomData/data$data_file.bin count=131072 bs=1
((data_file=data_file+1))

if [ $data_file -gt 200 ] ; then
break
fi

done


