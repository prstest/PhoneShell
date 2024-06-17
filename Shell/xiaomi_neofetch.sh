# 函数定义
All=$(dumpsys batterystats)
doze=$(echo "$All" | grep "Screen doze discharge" | awk '{print $4,$NF}')
doze_light=$(echo "$All" | grep "Device light doze discharge" | awk '{print $5,$NF}')
doze_deep=$(echo "$All" | grep "Device deep doze discharge" | awk '{print $5,$NF}')
ON=$(echo "$All" | grep "Screen on discharge" | awk '{print $4,$NF}')
OFF=$(echo "$All" | grep "Screen off discharge" | awk '{print $4,$NF}')

# 电池耗电
Power=$(echo "$All" | grep "#1:" | head -n "1")
battery=$(echo "$Power" | awk '{print $4}')
battery_now=$((battery - 1))
battery_time=$(echo "$Power" | awk '{print $2}')
minutes=$(echo "$battery_time" | awk -F 'm|s' '{sub(/^\+/,"",$1); print $1}')
seconds=$(echo "$battery_time" | awk -F 'm|s' '{print $2}')

bstatus=$(echo "$Power" | awk '{print $5,$6,$7}' | sed 's/[(),]//g')
bstatus1=$(echo "$bstatus" | awk '{print $1}')
bstatus2=$(echo "$bstatus" | awk '{print $2}')
bstatus3=$(echo "$bstatus" | awk '{print $3}')

BATTERY_LEVEL=$(dumpsys battery | grep level | awk '{print $2}')

# 颜色
bc="\033[38;5;33m"
b="\033[38;5;214m"
e="\033[0m"

# 电池
charge_full_design=$(cat /sys/class/power_supply/battery/charge_full_design)
cycle_count=$(cat /sys/class/power_supply/battery/cycle_count)
charge_full=$(cat /sys/class/power_supply/battery/charge_full)
JKD=$(echo "100*$charge_full/$charge_full_design" | bc)

# 墓碑
applist="$(pm list packages -3 2>&1 </dev/null)"
Filever=$(head -n 1 /data/system/NoActive/log | awk '{print $NF}')
Lspver=$(grep -l "modules" /data/adb/lspd/log/* | xargs sed -n '/当前版本/s/.*当前版本 \([0-9]*\).*/\1/p')
SMillet=$(dumpsys package com.sidesand.millet | grep versionName | awk -F' ' '{print $1}' | cut -d '=' -f2)

# 冻结
status=$(ps -A | grep -E "refrigerator|do_freezer|signal" | awk '{print "😴"$6 " " $9}' | grep -v Sandboxed | sort -t ' ' -k 1.1)
process1=$(echo "$status" | grep -v ":" | grep -vw "sh" | grep -c "")
webwive=$(ps -A | grep -E "refrigerator|do_freezer|signal" | grep Sandboxed | grep -c "")
process2=$(echo "$status" | grep -c "")
web=""

status=${status//"__refrigerator"/"😴 FreezerV1冻结中:"}
status=${status//"do_freezer_trap"/" FreezerV2冻结中:"}
#webwive=${webwive//"do_freezer_trap"/" FreezerV2冻结中:"}
status=${status//"do_signal_stop"/"😴 GSTOP冻结中:"}
status=${status//"get_signal"/" FreezerV2冻结中:"}
v1Info=$(mount | grep freezer | awk '{print "✔️已挂载 FreezerV1:", $3}')

xiaomi(){
echo "$bc db   db db    db d8888b. d88888b d8888b.    .d88b.  .d8888. $e"
echo "$bc 88   88 '8b  d8' 88  '8D 88'     88  '8D   .8P  Y8. 88'  YP $e"
echo "$bc 88ooo88  '8bd8'  88oodD' 88ooooo 88oobY'   88    88 '8bo. $e"
echo "$bc 88~~~88    88    88~~~   88~~~~~ 88'8b     88    88   'Y8b. $e"
echo "$bc 88   88    88    88      88.     88 '88.   '8b  d8' db   8D $e"
echo "$bc YP   YP    YP    88      Y88888P 88   YD    'Y88P'  '8888Y' $e"
echo " "

compile_time=$(uname -v)
datetime_part=$(echo "$compile_time" | awk '{print $6, $7, $8, $9, $10}')
time_part=$(echo "$compile_time" | awk '{print $7}')
Zram=$(cat /sys/block/zram0/comp_algorithm | cut -d '[' -f2 | cut -d ']' -f1)
tombstone=""
    if [ -e /sys/fs/cgroup/uid_0/cgroup.freeze ]; then
        tombstone="✔️已挂载 FreezerV2(UID)"
    elif [ -e /sys/fs/cgroup/freezer/perf/frozen/freezer.state ]; then
        tombstone="✔️已挂载 FreezerV1(FROZEN)"
    fi
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

echo "$b********************    安卓版本$e：$(getprop ro.build.version.release)"
echo "$b*                  *    手机型号$e：$(getprop ro.product.marketname) ($(getprop ro.product.board))"
echo "$b*    88     88     *    固件版本$e：$(getprop persist.sys.grant_version)"
echo "$b*    88b   d88     *    内核版本$e：$(uname -r | sed -e 's/-CUSTOMED//g')"
echo "$b*    88Yb dY88     *    编译时间$e：$(echo "$compile_time" | awk '{print $9}')年$chinese_month$(echo "$compile_time" | awk '{print $6}')日 $chinese_day $time_part"
echo "$b*    88 Y88Y88     *    处理器$e：$(getprop ro.soc.model)"
echo "$b*    88  Y  88     *    ZRAM大小$e："$(awk 'NR > 1 {size=$3/(1024*1024); printf "%.1fG\n", size}' /proc/swaps) "($Zram)"
echo "$b*    88     88     *    墓碑状态$e：$tombstone"
echo "$b*                  *$e    \033[41m   \033[0m\033[42m   \033[0m\033[43m   \033[0m\033[44m   \033[0m\033[45m   \033[0m\033[46m   \033[0m\033[47m   \033[0m\033[48m   \033[0m"
echo "$b********************$e    \033[41m   \033[0m\033[42m   \033[0m\033[43m   \033[0m\033[44m   \033[0m\033[45m   \033[0m\033[46m   \033[0m\033[47m   \033[0m\033[48m   \033[0m"
}
# 电池寿命
Battery() {
    echo ""
    echo "电池设计容量：$(echo "scale=0;$charge_full_design/1000" | bc)mAh"
    echo "循环次数：$cycle_count次"
    echo "电池当前充满：$(echo "scale=0;$charge_full/1000" | bc)mAh"
    echo "当前电池健康度：$JKD%"
    echo " "
}


# 翻译函数
status() {
    if [ "$bstatus1" == "screen-on" ]; then
        bstatus1="亮屏"
    else
        bstatus1="息屏"
    fi

    if [ "$bstatus2" == "power-save-on" ]; then
        bstatus2="省电模式已开启"
    else
        bstatus2="省电模式未开启"
    fi

    if [ "$bstatus3" == "device-idle-on" ]; then
        bstatus3="正处于Doze状态"
    else
        bstatus3="不处于Doze状态"
    fi
}

# 输出函数
output() {
    echo "亮屏电流：$ON"
    echo "息屏电流：$OFF"
    echo "Doze状态电流：$doze"
    echo "轻度Doze电流：$doze_light"
    echo "深度Doze电流：$doze_deep"
    echo "上一次电量：$battery"
    echo "现在电量：$battery_now"
    echo "总耗时：$minutes分$seconds秒"
    echo "电量从$battery到$battery_now的状态⬇️"
    echo "$bstatus1 $bstatus2 $bstatus3"
}

# 主函数
bater() {
    if [ "$BATTERY_LEVEL" == "$battery_now" ]; then
        status
        output
    else
        echo "电量不符合" $BATTERY_LEVEL $battery_now
    fi
}

# Root环境
Root() {
    echo ""
    if env | grep -qn 'ksu'; then
        echo "Root环境：KernelSU"
    elif echo "$applist" | grep -qw "io.github.huskydg.magisk"; then
        echo "Root环境：Magisk🦊"
    elif echo "$applist" | grep -qw "io.github.huskydg.magisk"; then
        echo "Root环境：Magisk"
    else
        echo "Root环境：未知"
    fi

    find /data/adb/modules/ -name 'module.prop' -exec awk -F= '/^name=/ {name=$2} /^version=/ {print " "++i"."" "name, $2}' {} +
    echo " "
}

# 墓碑
tombstone() {
    if [ -f "/data/system/NoActive/log" ] && [ "$(getprop persist.sys.powmillet.enable)" != "true" ]; then
        echo "墓碑：Noactive($Filever)"
    elif [ ! -z "$Lspver" ]; then
        echo "墓碑：Noactive($Lspver)"
    elif echo "$applist" | grep -qw "com.sidesand.millet1"; then
        echo "墓碑：SMillet($SMillet)"
    elif [ "$(getprop persist.sys.powmillet.enable)" = "true" ]; then
        echo "墓碑：Millet"
    else
        echo "未知的墓碑"
    fi

    #if [ -e /sys/fs/cgroup/uid_0/cgroup.freeze ]; then
       # echo "✔️已挂载 FreezerV2(UID)"
    #elif [ -e /sys/fs/cgroup/freezer/perf/frozen/freezer.state ]; then
        #echo "✔️已挂载 FreezerV1(FROZEN)"
    #fi

    if [ ${#v1Info} -gt 2 ]; then
        echo "$v1Info"
    fi
    
    if [ webwive != null ];then
      web="\033[33m[ 注意：WebView已经隐藏 ]\033[0m"
    fi

    if [ ${#status} -gt 2 ]; then
        echo "==============[ 冻结状态 ]==============
$status
"[  已冻结"$process1"个应用和"$webwive"个WebView"总共有$process2"个进程被冻结" ]
$web"
    else
        echo "暂无冻结状态的进程"
    fi
}
manu=$(getprop ro.product.manufacturer)
if [ "$manu" == "Xiaomi" ]; then 
xiaomi
fi

Battery
bater
Root
tombstone