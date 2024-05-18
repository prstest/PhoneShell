#!/system/bin/sh
MODDIR=${0%/*}

# 获取NoActive日志中的最新条目
latest_entry=$(head -n 1 /data/system/NoActive/log | awk '{print $NF}')

freezer_info=""
if [ -e /sys/fs/cgroup/uid_0/cgroup.freeze ]; then
    freezer_info="冻结方式：FreezerV2(UID)"
elif [ -e /sys/fs/cgroup/freezer/perf/frozen/freezer.state ]; then
    freezer_info="冻结方式：FreezerV1(FROZEN)"
else
    v1Info=$(mount | grep freezer | awk '{print "✔️已挂载 FreezerV1:", $3}')
    if [ ${#v1Info} -gt 2 ]; then
        freezer_info=$v1Info
    else
        freezer_info="冻结方式未知"
    fi
fi

# 添加附加信息
additional_info="已关闭Millet，现在由Noactive接管"

# 构建新的描述
new_description="NoActive版本：$latest_entry                                                                     $freezer_info                                                                $additional_info"

# 使用 sed 替换 module.prop 文件中的 description 行
sed -i "s/^description=.*/description=$new_description/" $MODDIR/module.prop