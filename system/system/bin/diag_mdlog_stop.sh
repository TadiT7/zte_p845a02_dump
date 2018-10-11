#!/system/bin/sh
PATH=$PATH:/system/vendor/xbin/

echo "stop diag_mdlog" > /cache/op_logs.txt
toybox pkill -SIGINT diag_mdlog
