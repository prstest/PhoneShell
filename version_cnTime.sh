#查看内核
echo "手机型号：$(getprop ro.product.model)"
echo "内核版本：$(uname -r)"
echo "内核架构：$(uname -s) $(uname -m)"
echo "内核信息：$(cat /proc/version | cut -d'(' -f3 | cut -d')' -f1)"
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
echo "编译时间: $(echo "$compile_time" | awk '{print $9}')年$chinese_month$(echo "$compile_time" | awk '{print $6}')日 $chinese_day $time_part"
echo "处理器：$(cat /proc/cpuinfo | grep -m1 "Hardware" | cut -d':' -f2 | sed 's/^[ \t]*//')"
echo "ZRAM大小："$(awk 'NR > 1 {size=$3/(1024*1024); printf "%.1fG\n", size}' /proc/swaps)
package_name1="me.weishu.kernelsu"
package_name2="cn.myflv.noactive"
if pm list packages | grep -qw "$package_name1"; 
then
    echo "Root环境：KernelSU"
fi
echo "你拥有的Root模块"
find /data/adb/modules/ -name 'module.prop' -exec awk -F= '/^name=/ {name=$2} /^version=/ {print "😋", name, "" $2 ""}' {} +
echo " "

#查看电池 传播者：Rock&Z
charge_full=`su -c cat /sys/class/power_supply/battery/charge_full`
charge_full_design=`su -c cat /sys/class/power_supply/battery/charge_full_design`
cycle_count=`su -c cat /sys/class/power_supply/battery/cycle_count`
echo "电池设计容量：$(echo "scale=0;$charge_full_design/1000"|bc)mAh"
echo "循环次数：$cycle_count次"
echo "电池当前充满：$(echo "scale=0;$charge_full/1000"|bc)mAh"
JKD=$(echo "100*$charge_full/$charge_full_design"|bc)
echo "当前电池健康度：$JKD%"
echo " "

# 查看冻结源码 作者：JARK006
vers=$(head -n 1 /data/system/NoActive/log | awk '{print $NF}')
if pm list packages | grep -qw "$package_name2"; then
    echo "墓碑环境：Noactive($vers)"
fi
if [ -e /sys/fs/cgroup/uid_0/cgroup.freeze ]; then
    echo "✔️已挂载 FreezerV2(UID)"
fi

if [[ -e /sys/fs/cgroup/frozen/cgroup.freeze ]] && [[ -e /sys/fs/cgroup/unfrozen/cgroup.freeze ]]; then
    echo "✔️已挂载 FreezerV2(FROZEN)"
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
status=${status//"do_signal_stop"/"😴꓉GSTOP冻结中:"}
status=${status//"get_signal"/"😴 可能是FreezerV2冻结中:"}

if [ ${#status} -gt 2 ]; then
echo "==============[ 冻结状态 ]==============
$status"
else
    echo "暂无冻结状态的进程"
fi