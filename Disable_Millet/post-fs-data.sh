#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}
resetprop -n sys.millet.monitor 1
resetprop -n persist.sys.gz.enable false
resetprop -n persist.sys.brightmillet.enable false
resetprop -n persist.sys.powmillet.enable false
resetprop -n persist.sys.millet.handshake true
# This script will be executed in post-fs-data mode