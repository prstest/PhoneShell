#!/system/bin/sh
if [ $MAGISK_VER_CODE -eq 27005] && [ -z $KSU ] && [ -z $APATCH ]; then
    ui_print "- 检测到Magisk版本为27005，已停止安装"
    ui_print "- 请更新Magisk之后重新安装该模块"
    abort "Stop installation Module"
fi