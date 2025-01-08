#!/system/bin/sh

MODDIR=${0%/*}

resetprop -w sys.boot_completed 0

chmod +x $MODDIR/SCM

./SCM &