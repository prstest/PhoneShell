# 判断NoActive目录
new_log_path=$(ls /data/system/ | grep NoActive_)
if [[ -f "/data/system/$new_log_path/log" && -f "/data/system/NoActive/log" ]]; then
    NoActive_file="/data/system/$new_log_path"
elif [ -f "/data/system/NoActive/log" ]; then
    NoActive_file="/data/system/NoActive"
elif [ -f "/data/system/$new_log_path/log" ]; then
    NoActive_file="/data/system/$new_log_path"
fi
commandInject=$(grep '"commandInject":true' $NoActive_file/config/MasterConfig.json)

get(){
# 提示用户输入内容
setenforce 0
echo "正在获取应用列表..."

# 读取用户输入并存储到变量中
applist=$(pm list packages $1 | sed -e 's/package://g')

# 设置IFS变量为只包含换行的字符串
IFS=$'\n'

# 将输入字符串分割成数组
my_array=($applist)

# 恢复IFS变量的默认值
unset IFS

# 初始化计数器和数组
isSystemCount=0
isIgnoreCount=0
isFrozenCount=0
isOngoingNowCount=0
isVisibleNowCount=0
isPlayNowCount=0
isWindowNowCount=0
isLocationNowCount=0
isRecordNowCount=0
isVpnNowCount=0
isBackupNowCount=0
isAccessibilityNowCount=0

systemApps=()
ignoreApps=()
frozenApps=()
ongoingNowApps=()
visibleNowApps=()
playNowApps=()
windowNowApps=()
locationNowApps=()
recordNowApps=()
vpnNowApps=()
backupNowApps=()
accessibilityNowApps=()

# 输出数组中的每个元素
for element in "${my_array[@]}"
do
    # 获取查询结果
    query_result=$(pm freezer query 0#$element)

    # 检查并递增相应的计数器
    if [[ $query_result == *"isSystem: true"* ]]; then
        ((isSystemCount++))
        systemApps+=("$element")
    fi
    if [[ $query_result == *"isIgnore: true"* ]]; then
        ((isIgnoreCount++))
        ignoreApps+=("$element")
    fi
    if [[ $query_result == *"isFrozen: true"* ]]; then
        ((isFrozenCount++))
        frozenApps+=("$element")
    fi
    if [[ $query_result == *"isOngoingNow: true"* ]]; then
        ((isOngoingNowCount++))
        ongoingNowApps+=("$element")
    fi
    if [[ $query_result == *"isVisibleNow: true"* ]]; then
        ((isVisibleNowCount++))
        visibleNowApps+=("$element")
    fi
    if [[ $query_result == *"isPlayNow: true"* ]]; then
        ((isPlayNowCount++))
        playNowApps+=("$element")
    fi
    if [[ $query_result == *"isWindowNow: true"* ]]; then
        ((isWindowNowCount++))
        windowNowApps+=("$element")
    fi
    if [[ $query_result == *"isLocationNow: true"* ]]; then
        ((isLocationNowCount++))
        locationNowApps+=("$element")
    fi
    if [[ $query_result == *"isRecordNow: true"* ]]; then
        ((isRecordNowCount++))
        recordNowApps+=("$element")
    fi
    if [[ $query_result == *"isVpnNow: true"* ]]; then
        ((isVpnNowCount++))
        vpnNowApps+=("$element")
    fi
    if [[ $query_result == *"isBackupNow: true"* ]]; then
        ((isBackupNowCount++))
        backupNowApps+=("$element")
    fi
    if [[ $query_result == *"isAccessibilityNow: true"* ]]; then
        ((isAccessibilityNowCount++))
        accessibilityNowApps+=("$element")
    fi
done

# 输出结果
#clear
if [ ${#systemApps[@]} -ne 0 ]; then
    echo "系统应用"
    for app in "${systemApps[@]}"; do
        echo "$app"
    done
fi

if [ ${#ignoreApps[@]} -ne 0 ]; then
    echo "白名单应用"
    for app in "${ignoreApps[@]}"; do
        echo "$app"
    done
fi

if [ ${#frozenApps[@]} -ne 0 ]; then
    echo "冻结应用"
    for app in "${frozenApps[@]}"; do
        echo "$app"
    done
fi

if [ ${#ongoingNowApps[@]} -ne 0 ]; then
    echo "正在进行应用"
    for app in "${ongoingNowApps[@]}"; do
        echo "$app"
    done
fi

if [ ${#visibleNowApps[@]} -ne 0 ]; then
    echo "可见应用"
    for app in "${visibleNowApps[@]}"; do
        echo "$app"
    done
fi

if [ ${#playNowApps[@]} -ne 0 ]; then
    echo "正在播放应用"
    for app in "${playNowApps[@]}"; do
        echo "$app"
    done
fi

if [ ${#windowNowApps[@]} -ne 0 ]; then
    echo "窗口应用"
    for app in "${windowNowApps[@]}"; do
        echo "$app"
    done
fi

if [ ${#locationNowApps[@]} -ne 0 ]; then
    echo "位置应用"
    for app in "${locationNowApps[@]}"; do
        echo "$app"
    done
fi

if [ ${#recordNowApps[@]} -ne 0 ]; then
    echo "录音应用"
    for app in "${recordNowApps[@]}"; do
        echo "$app"
    done
fi

if [ ${#vpnNowApps[@]} -ne 0 ]; then
    echo "VPN应用"
    for app in "${vpnNowApps[@]}"; do
        echo "$app"
    done
fi

if [ ${#backupNowApps[@]} -ne 0 ]; then
    echo "备份应用"
    for app in "${backupNowApps[@]}"; do
        echo "$app"
    done
fi

if [ ${#accessibilityNowApps[@]} -ne 0 ]; then
    echo "无障碍应用"
    for app in "${accessibilityNowApps[@]}"; do
        echo "$app"
    done
fi

# 输出计数器的值
echo ""
echo "计数结果如下："
echo "系统应用: $isSystemCount"
echo "白名单应用: $isIgnoreCount"
echo "冻结应用: $isFrozenCount"
echo "未冻结应用: $isOngoingNowCount"
echo "前台可见应用: $isVisibleNowCount"
echo "正在播放应用: $isPlayNowCount"
echo "窗口应用: $isWindowNowCount"
echo "位置应用: $isLocationNowCount"
echo "录音应用: $isRecordNowCount"
echo "VPN应用: $isVpnNowCount"
echo "备份应用: $isBackupNowCount"
echo "无障碍应用: $isAccessibilityNowCount"
echo ""
echo "[数据来自Noactive命令注入后返回的结果,数据仅供参考]"
setenforce 1
}
single(){
pm freezer query 0#$1
}

main(){
echo "1. 全部应用"
echo "2. 第三方应用"
echo "3. 单应用查询"
echo -n "请输入序号："
read input

if [ "$input" = "1" ]; then
    get
elif [ "$input" = "2" ]; then
    get -3
elif [ "$input" = "3" ]; then
    echo -n "请输入包名："
    read app
    single $app
else
   echo "输入的序号有误，程序已退出"
   exit
fi
}
# 检查 commandInject 是否为 true
if [ -n "$commandInject" ]; then
 main
else 
 echo "命令注入未开启"
fi