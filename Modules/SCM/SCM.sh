#!/bin/sh

# 定义
MODDIR=${0%/*}
config_file="$MODDIR/config/config.env"
count_file="$MODDIR/config/count.env"
switch="/sys/class/power_supply/battery/input_suspend"
log_file="$MODDIR/config/log.txt"
input=$(cat /sys/class/power_supply/battery/constant_charge_current_max)
time=$(date "+%Y-%m-%d %H:%M:%S")

> $log_file

# 检查配置文件是否存在
if [ ! -f "$config_file" ]; then
    echo "配置文件 $config_file 不存在"
    exit 1
fi

# 加载配置文件和计数文件
source "$config_file"
source "$count_file"

main() {
    while true; do
        # 重新加载配置文件和计数文件
        if [ ! -f "$config_file" ]; then
            echo "配置文件 $config_file 不存在"
            exit 1
        fi

        source "$config_file"
        source "$count_file"

        if [ ! -r "/sys/class/power_supply/battery/current_now" ]; then
            echo "无法读取 /sys/class/power_supply/battery/current_now"
            exit 1
        fi

        current=$(cat /sys/class/power_supply/battery/current_now)
        level=$(dumpsys battery | grep level | awk '{print $NF}')
        time=$(date "+%Y-%m-%d %H:%M:%S")
        up_strat=$((start_count + 1))
        up_stop=$((stop_count + 1))
        input=$(cat /sys/class/power_supply/battery/constant_charge_current_max)

        # 记录日志
        # echo "$time [调试] 电量: $level | 电流: $current | 模式: $(cat $switch)" >> "$log_file"

        # 恢复充电逻辑
        if [ "$level" -le "$start" ] && [ "$(cat $switch)" -eq 1 ]; then
            if echo 0 > "$switch"; then
                echo "$time [信息] 电量: $level | 电流: $current | 已恢复充电" >> "$log_file"
                # 更新计数文件中的 start_count
                sed -i "s/^start_count=.*/start_count=${up_strat}/" "$count_file"
            else
                echo "$time | 写入 $switch 文件失败" >> "$log_file"
            fi
        fi

        # 停止充电逻辑
        if [ "$Trickle" == "true" ]; then
            if [ "$level" -eq "$stop" ] && [ "$current" -eq "$stop_current" ]; then
                if echo 1 > "$switch"; then
                    echo "$time [信息] 电量: $level | 电流: $current | 已停止充电" >> "$log_file"
                    # 更新计数文件中的 stop_count
                    sed -i "s/^stop_count=.*/stop_count=${up_stop}/" "$count_file"
                else
                    echo "$time | 写入 $switch 文件失败" >> "$log_file"
                fi
            fi
        else
            if [ "$level" -eq "$stop" ]; then
                if echo 1 > "$switch"; then
                    echo "$time [信息] 电量: $level | 电流: $current | 已停止充电" >> "$log_file"
                    # 更新计数文件中的 stop_count
                    sed -i "s/^stop_count=.*/stop_count=${up_stop}/" "$count_file"
                else
                    echo "$time | 写入 $switch 文件失败" >> "$log_file"
                fi
            fi
        fi
        
        # 检查 input_max 是否等于 constant_charge_current_max
        if [ "$input_max" != "$input" ]; then
            echo $input_max > /sys/class/power_supply/battery/constant_charge_current_max
          echo "$time [配置] 最大电流已更新：$input_maxµA" >> "$log_file"
        fi

        sleep "$stoptime"

        # 检查主开关状态
        if [ "$main_switch" -ne 1 ]; then
            echo "$time | 主开关已关闭，程序终止" >> "$log_file"
            break
        fi
    done
}

if [ "$main_switch" -eq 1 ]; then
    echo "$time 已成功开启定量停充" >> "$log_file"
    sleep 3
    echo "$time [配置] 停止电量：$stop% 
$time [配置] 恢复电量：$start%
$time [配置] 停充电流：$stop_currentµA
$time [配置] 完全充满：$Trickle
$time [配置] 最大电流：$input_maxµA" >> "$log_file"
    main
else
    echo "程序已终止" >> "$log_file"
fi
