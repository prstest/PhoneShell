# 获取NoActive日志中的最新条目
NoactiveVer=""
if [ -f "/data/system/NoActive/log" ]; then
    Filever=$(head -n 1 /data/system/NoActive/log | awk '{print $NF}')
    NoactiveVer=$Filever
fi

Lspver=$(grep -l "modules" /data/adb/lspd/log/* | xargs sed -n '/当前版本/s/.*当前版本 \([0-9]*\).*/\1/p')
if [ -n "$Lspver" ]; then
    NoactiveVer=$Lspver
fi

freezer_info=""
if [ -e /sys/fs/cgroup/freezer/perf/frozen/freezer.state ]; then
    freezer_info="冻结方式：FreezerV1(FROZEN)"
elif [ -e /sys/fs/cgroup/uid_0/cgroup.freeze ]; then
    freezer_info="冻结方式：FreezerV2(UID)"
fi
additional_info=""
if [ "$(getprop persist.sys.powmillet.enable)" = "true" ]; then additional_info="Millet处于运行状态，将在下一次重启时关闭"
else additional_info="已关闭Millet，现在由Noactive接管"
fi

ui_print "当前版本：$NoactiveVer"
ui_print "冻结方式：$freezer_info"
ui_print "$additional_info"

ui_print "你已经成功安装 Disable Millet"