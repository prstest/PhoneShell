AB_check=$(getprop ro.build.ab_update)
Partition_location=$(getprop ro.boot.slot_suffix)
subzone=$(ls /dev/block/bootdevice/by-name)
echo "正在检测你的手机是否为AB区"
if [ $AB_check == true ]; then
    echo "你的是手机是AB分区设备"
    if [ $Partition_location == _a ]; then
        echo "你的目前处于A分区"
        Current=a
    elif [ $Partition_location == _b ]; then
        echo "你的目前处于B分区"
        Current=b
    fi
else
    echo "你的是手机不是AB分区设备"
fi

echo "你目前拥有的分区"
ls /dev/block/bootdevice/by-name

echo ""

Extraction(){
    position=$(ls -l /dev/block/bootdevice/by-name/$1 | awk '{print $NF}')
    # echo $position
    dd if=$position of=$origin
    echo "已成功提取$Withdraw到$origin"
}

echo -n "请输入你想要提取的分区: "
read Withdraw
echo 你选择提取$Withdraw,正在查询是否存在此分区
if echo "$subzone" | grep -qw "$Withdraw"; then
    echo "确认存在此分区，正在提取"
    origin="/sdcard/Download/$Withdraw.img"
    Extraction $Withdraw
else
    echo "未找到该分区，程序终止"
fi



