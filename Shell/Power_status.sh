# 函数定义
All=$(dumpsys batterystats)
doze=$(echo "$All" | grep "Screen doze discharge" | awk '{print $4,$NF}')
doze_light=$(echo "$All" | grep "Device light doze discharge" | awk '{print $5,$NF}')
doze_deep=$(echo "$All" | grep "Device deep doze discharge" | awk '{print $5,$NF}')
ON=$(echo "$All" | grep "Screen on discharge" | awk '{print $4,$NF}')
OFF=$(echo "$All" | grep "Screen off discharge" | awk '{print $4,$NF}')

Power=$(echo "$All" | grep "#1:" | head -n "1")
battery=$(echo "$Power" | awk '{print $4}')
battery_now=$((battery - 1))
battery_time=$(echo "$Power" | awk '{print $2}')
minutes=$(echo "$battery_time" | awk -F 'm|s' '{sub(/^\+/,"",$1); print $1}')
seconds=$(echo "$battery_time" | awk -F 'm|s' '{print $2}')

status=$(echo "$Power" | awk '{print $5,$6,$7}' | sed 's/[(),]//g')
status1=$(echo "$status" | awk '{print $1}')
status2=$(echo "$status" | awk '{print $2}')
status3=$(echo "$status" | awk '{print $3}')

BATTERY_LEVEL=$(dumpsys battery | grep level | awk '{print $2}')

# 翻译函数
status() {
    if [ "$status1" == "screen-on" ]; then
        status1="亮屏"
    else
        status1="息屏"
    fi

    if [ "$status2" == "power-save-on" ]; then
        status2="省电模式已开启"
    else
        status2="省电模式未开启"
    fi

    if [ "$status3" == "device-idle-on" ]; then
        status3="正处于Doze状态"
    else
        status3="不处于Doze状态"
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
    echo "$status1 $status2 $status3"
}

# 主函数
main() {
    if [ "$BATTERY_LEVEL" == "$battery_now" ]; then
        status
        output
    else
        echo "电量不符合battery_now，请拔掉充电器，掉一格电后再运行"
    fi
}
main
