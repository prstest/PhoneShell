#!/system/bin/sh
MODDIR=${0%/*}

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

# 添加附加信息
additional_info="已关闭Millet，现在由Noactive接管"

# 构建新的描述
new_description="NoActive版本：$NoactiveVer                                                                             $freezer_info                                                                $additional_info"

# 使用 sed 替换 module.prop 文件中的 description 行
sed -i "s/^description=.*/description=$new_description/" $MODDIR/module.prop
