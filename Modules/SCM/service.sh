#!/system/bin/sh

MODDIR=${0%/*}

while [ "$(getprop 'sys.boot_completed')" != '1' ]; do sleep 1; done

chmod +x $MODDIR/SCM

./SCM &