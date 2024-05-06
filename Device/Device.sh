if getprop ro.product.odm.marketname >/dev/null 2>&1; then
    echo "手机型号：$(getprop ro.product.odm.marketname) ($(getprop ro.product.board))"
fi
if getprop ro.build.version.release >/dev/null 2>&1; then
    echo "安卓版本：$(getprop ro.build.version.release)"
fi
if getprop ro.build.version.security_patch >/dev/null 2>&1; then
    echo "安全补丁：$(getprop ro.build.version.security_patch)"
fi
if getprop persist.sys.grant_version >/dev/null 2>&1; then
    echo "固件版本：$(getprop persist.sys.grant_version)"
fi
echo "内核版本：$(uname -r)"
compile_time=$(uname -v)
datetime_part=$(echo "$compile_time" | awk '{print $6, $7, $8, $9, $10}')
case $(echo "$compile_time" | awk '{print $5}') in
    "Jan") chinese_month="1月" ;;
    "Feb") chinese_month="2月" ;;
    "Mar") chinese_month="3月" ;;
    "Apr") chinese_month="4月" ;;
    "May") chinese_month="5月" ;;
    "Jun") chinese_month="6月" ;;
    "Jul") chinese_month="7月" ;;
    "Aug") chinese_month="8月" ;;
    "Sep") chinese_month="9月" ;;
    "Oct") chinese_month="10月" ;;
    "Nov") chinese_month="11月" ;;
    "Dec") chinese_month="12月" ;;
    *) chinese_month="未知" ;;
esac
case $(echo "$compile_time" | awk '{print $4}') in
    "Mon") chinese_day="星期一" ;;
    "Tue") chinese_day="星期二" ;;
    "Wed") chinese_day="星期三" ;;
    "Thu") chinese_day="星期四" ;;
    "Fri") chinese_day="星期五" ;;
    "Sat") chinese_day="星期六" ;;
    "Sun") chinese_day="星期日" ;;
    *) chinese_day="未知" ;;
esac
time_part=$(echo "$compile_time" | awk '{print $7}')
echo "编译时间：$(echo "$compile_time" | awk '{print $9}')年$chinese_month$(echo "$compile_time" | awk '{print $6}')日 $chinese_day $time_part"
if getprop getprop ro.soc.model >/dev/null 2>&1; then
    echo "处理器：$(getprop ro.soc.model)"
fi
zip=$(cat /sys/block/zram0/comp_algorithm | cut -d '[' -f2 | cut -d ']' -f1)
echo "ZRAM大小："$(awk 'NR > 1 {size=$3/(1024*1024); printf "%.1fG\n", size}' /proc/swaps) "($zip)"

echo ""

#查看电池 传播者：Rock&Z
if [ -f "/sys/class/power_supply/battery/charge_full_design" ]; then
    charge_full_design=$(su -c cat /sys/class/power_supply/battery/charge_full_design)
    echo "电池设计容量：$(echo "scale=0;$charge_full_design/1000"|bc)mAh"
fi

if [ -f "/sys/class/power_supply/battery/cycle_count" ]; then
    cycle_count=$(su -c cat /sys/class/power_supply/battery/cycle_count)
    echo "循环次数：$cycle_count次"
fi

if [ -f "/sys/class/power_supply/battery/charge_full" ]; then
    charge_full=$(su -c cat /sys/class/power_supply/battery/charge_full)
    echo "电池当前充满：$(echo "scale=0;$charge_full/1000"|bc)mAh"
fi

if [ -f "/sys/class/power_supply/battery/charge_full" ] && [ -f "/sys/class/power_supply/battery/charge_full_design" ]; then
    JKD=$(echo "100*$charge_full/$charge_full_design"|bc)
    echo "当前电池健康度：$JKD%"
fi
echo " "

if env | grep -qn 'ksu'; 
then
    echo "Root环境：KernelSU"
fi

if pm list packages | grep -qw "io.github.huskydg.magisk"; then
    echo "Root环境：Magisk🦊"
fi

find /data/adb/modules/ -name 'module.prop' -exec awk -F= '/^name=/ {name=$2} /^version=/ {print " 😋 ", name, "" $2 ""}' {} +
echo " "

# 查看冻结源码 作者：JARK006
if [ -f "/data/system/NoActive/log" ]; then
    Filever=$(head -n 1 /data/system/NoActive/log | awk '{print $NF}')
    echo "墓碑环境：Noactive($Filever)"
fi
Lspver=$(grep -l "modules" /data/adb/lspd/log/* | xargs sed -n '/当前版本/s/.*当前版本 \([0-9]*\).*/\1/p')
if [ ! -z "$Lspver" ]; then
echo "墓碑环境：Noactive($Lspver)"
fi
apk=$(dumpsys package com.sidesand.millet | grep versionName | awk -F' ' '{print $1}' | cut -d '=' -f2)
if pm list packages | grep -qw "com.sidesand.millet1"; then
    echo "墓碑环境：SMillet($apk)"
fi
#echo "墓碑环境：Millet😇"
if [ -e /sys/fs/cgroup/uid_0/cgroup.freeze ]; then
    echo "✔️已挂载 FreezerV2(UID)"
fi
if [ -e /sys/fs/cgroup/freezer/perf/frozen/freezer.state ]; then
    echo "✔️已挂载 FreezerV1(FROZEN)"
fi
v1Info=$(mount | grep freezer | awk '{print"✔️已挂载 FreezerV1:",$3}')
if [ ${#v1Info} -gt 2 ]; then
    echo "$v1Info"
fi

status=$(ps -A | grep -E "refrigerator|do_freezer|signal" | awk '{print $6 " " $9}')
status=${status//"__refrigerator"/"😴 FreezerV1冻结中:"}
status=${status//"do_freezer_trap"/"😴 FreezerV2冻结中:"}
status=${status//"do_signal_stop"/"😴 GSTOP冻结中:"}
status=${status//"get_signal"/"😴 FreezerV2冻结中:"}

if [ ${#status} -gt 2 ]; then
echo "==============[ 冻结状态 ]==============
$status"
else
    echo "暂无冻结状态的进程"
fi