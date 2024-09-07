#!/bin/bash

# 颜色定义
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;36m"
END="\033[0m"

# 检查是否是 root 用户
if [ "$(whoami)" != "root" ]; then
    echo "请使用 Root 权限运行此脚本"
    exit 1
fi

# 检查是否存在分区路径
if [ ! -d "/dev/block/bootdevice/by-name" ]; then
    echo "未检测到分区路径，此脚本可能不适合你"
    exit 1
fi


while true; do
    init() {
        # 初始变量定义
        AB_check=$(getprop ro.build.ab_update)
        Partition_location=$(getprop ro.boot.slot_suffix)
        subzone=$(ls /dev/block/bootdevice/by-name)

        # 判断AB设备
        if [ "$AB_check" == "true" ]; then
            echo "你的手机是 AB 分区设备"
            if [ "$Partition_location" == "_a" ]; then
                echo "你目前处于 A 分区"
                Current="a"
            elif [ "$Partition_location" == "_b" ]; then
                echo "你目前处于 B 分区"
                Current="b"
            fi
        else
            echo "你的手机不是 AB 分区设备"
        fi

        echo "你目前拥有的分区:"
        ls /dev/block/bootdevice/by-name
        echo ""
    }

    ASCII() {
        echo -e "$1
  ____            _   _ _   _           _____           _
 |  _ \ __ _ _ __| |_(_) |_(_) ___  _ __|_   _|__   ___ | |
 | |_) / _\` | '__| __| | __| |/ _ \| '__ \| |/ _ \ / _ \| |
 |  __/ (_| | |  | |_| | |_| | (_) | | | | | (_) | (_) | |
 |_|   \__,_|_|   \__|_|\__|_|\___/|_| |_|_|\___/ \___/|_|
$END"
    }

    # 提取分区主函数
    Extraction_main() {
        echo -n "请输入你想要提取的分区: "
        read -r Withdraw
        echo "你选择提取 $Withdraw, 正在查询是否存在此分区"

        if echo "$subzone" | grep -qw "$Withdraw"; then
            echo "确认存在此分区，正在提取"
            origin="/sdcard/Download/$Withdraw.img"
            Extraction "$Withdraw"
            echo "已成功提取 $Withdraw 到 $origin"
        else
            echo "未找到该分区，程序终止"
        fi
    }

    # 提取分区函数
    Extraction() {
        position=$(ls -l /dev/block/bootdevice/by-name/$1 | awk '{print $NF}')
        dd if="$position" of="$origin" bs=4M
    }

    # 刷入分区主函数
    Flash_main() {
        echo -n "请输入你想要刷入的分区: "
        read -r Partition
        echo -n "请输入镜像文件的绝对路径: "
        read -r Partition_path
        echo "你选择刷入 $Partition 分区, 正在查询是否存在此分区"

        if echo "$subzone" | grep -qw "$Partition"; then
            echo "确认存在此分区"
            echo -n "在刷入分区前，你是否选择备份一次分区？(y/n): "
            read -r backup_options
            if [ "$backup_options" = "y" ]; then
                origin="/sdcard/Download/${Partition}_backup.img"
                Extraction "$Partition"
                echo "已成功备份 $Partition 到 $origin"
            fi
            echo "刷入的分区：$Partition"
            echo "刷入的镜像路径：$Partition_path"
            echo "刷入的镜像 md5 值：$(md5sum "$Partition_path" | awk '{print $1}')"
            echo -n -e "$RED最后让我们确认一下，刷入的镜像和分区信息是否正确，确认无误输入 y 后回车 (y/n):$END "
            read -r confirm_flash
            if [ "$confirm_flash" = "y" ]; then
                echo "开始刷入镜像..."
                Flash "$Partition" "$Partition_path"
            else
                echo "刷入镜像操作已取消"
            fi
        else
            echo "未找到该分区，程序终止"
        fi
    }

    # 刷入分区函数
    Flash() {
        position=$(ls -l /dev/block/bootdevice/by-name/$1 | awk '{print $NF}')
        dd if="$2" of="$position" bs=4M
        echo "已成功刷入 $1"

        echo -n "你是否选择重启？(y/n): "
        read -r reboot

        if [ "$reboot" = "y" ]; then
            echo "你选择了重启，将在 3 秒后重启你的设备"
            sleep 3
            reboot
        else
            echo "重启操作已取消"
        fi
    }

    # 主函数
    main() {
        ASCII $BLUE
        echo -e "${GREEN}1. 提取分区$END"
        echo -e "${RED}2. 刷入分区$END"
        echo -n "请输入序号："
        read -r Function
        if [ "$Function" -eq 1 ]; then
            clear
            ASCII $GREEN
            echo "你选择了提取分区"
            init
            Extraction_main
        elif [ "$Function" -eq 2 ]; then
            clear
            ASCII $RED
            echo "你选择了刷入分区"
            echo -e "$RED注意：刷入镜像前请仔细检查分区和镜像信息\n因为这是一个有风险的操作，如果出现问题，作者概不负责$END"
            init
            Flash_main
        else
            echo "无效的输入，请重新输入"
        fi
    }

    main

    # 中断函数
    echo -n "是否继续操作？(y/n): "
    read -r response
    if [ "$response" != "y" ]; then
        break
    fi
    clear
done
