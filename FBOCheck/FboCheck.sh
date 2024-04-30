echo FBO环境检查：
if [ "$(getprop persist.sys.fboservice.ctrl)" = "true" ]; then
    echo FBO已启动 😋
else
    echo FBO未开启 😭
    echo 请查看persist.sys.fboservice.ctrl是否为true
    echo
fi
if [ "$(getprop init.svc.fbo-installd)" = "running" ]; then
    echo init_FBO正在运行 😋
else
    echo init_FBO已停止 😭
    echo 请查看init.svc.fbo-installd 是否为running
    echo
fi

if [ "$(getprop persist.sys.stability.miui_fbo_enable)" = "true" ]; then
    echo MIUI_FBO已启动 😋
else
    echo MIUI_FBO未开启 😭
    echo 请查看persist.sys.stability.miui_fbo_enable是否为true
    echo
fi
if [ -f "/system_ext/etc/init/memory.fbo.native@1.0-service.rc" ] ||［ -f "/system/etc/init/memory.fbo.native@1.0-service.rc"］; then
    echo fbo.native.rc存在 😋
else 
    echo rc文件不存在 😭
    echo 请查看目录/system_ext/etc/init/init确认memory.fbo.native@1.0-service.rc是否存在
    echo
fi

if [ -f "/system_ext/bin/FboNativeService" ]; then
    echo FboNativeService存在 😋
else 
    echo FboNativeService不存在 😭
    echo 请查看目录/system_ext/bin/是否存在FboNativeService
fi

echo

echo "FBO触发条件判断:"
HOUR=$(date +%H)
if (( HOUR >= 0 && HOUR < 5 )); then
    echo "当前时间：在凌晨0时到5时范围内 ✔️ "
else
    echo "当前时间：不在凌晨0时到5时范围内 ❌"
fi

BATTERY_TEMP=$(cat /sys/class/power_supply/battery/temp)
if [ $BATTERY_TEMP -le 400 ]; then
    echo "电池温度：未超过400 ✔️"
else
    echo "电池温度：超过400，无法触发FBO进程 ❌"
fi

USB_CONNECTED=$(cat /sys/class/power_supply/usb/online)
if [ $USB_CONNECTED -eq 0 ]; then
    echo "电脑连接：未连接电脑 ✔️"
else
    echo "电脑连接：电脑连接中，无法触发FBO进程 ❌"
fi

SCREEN_STATUS=$(dumpsys power | grep mScreenOn=true)
if [ -z "$SCREEN_STATUS" ]; then
    echo "屏幕状态：屏幕已亮起，无法触发FBO进程 ❌"
else
    echo "屏幕状态：屏幕未亮起 ✔️"
fi

BATTERY_LEVEL=$(dumpsys battery | grep level | awk '{print $2}')
if [ $BATTERY_LEVEL -ge 75 ]; then
    echo "电量状态：电量高于或等于75% ✔️"
else
    echo "电量状态：电量低于75%，无法触发FBO进程 ❌"
fi
