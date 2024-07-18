echo FBO环境检查：
if [ "$(getprop persist.sys.fboservice.ctrl)" = "true" ]; then
    echo FBO已启动 ✔️
else
    echo FBO未开启 ❌
    echo 请查看persist.sys.fboservice.ctrl是否为true
    echo
fi
if [ "$(getprop init.svc.fbo-installd)" = "running" ]; then
    echo init_FBO正在运行 ✔️
else
    echo init_FBO已停止 ❌
    echo 请查看init.svc.fbo-installd 是否为running
    echo
fi

if [ "$(getprop persist.sys.stability.miui_fbo_enable)" = "true" ]; then
    echo MIUI_FBO已启动 ✔️
else
    echo MIUI_FBO未开启 ❌
    echo 请查看persist.sys.stability.miui_fbo_enable是否为true
    echo
fi
if [ -f "/system_ext/etc/init/memory.fbo.native@1.0-service.rc" ] ||［ -f "/system/etc/init/memory.fbo.native@1.0-service.rc"］; then
    echo fbo.native.rc存在 ✔️
else 
    echo rc文件不存在 ❌
    echo 请查看目录/system_ext/etc/init/init确认memory.fbo.native@1.0-service.rc是否存在
    echo
fi

if [ -f "/system_ext/bin/FboNativeService" ]; then
    echo FboNativeService存在 ✔️
else 
    echo FboNativeService不存在 ❌
    echo 请查看目录/system_ext/bin/是否存在FboNativeService
fi

if ps -ef | grep -q '[F]boNativeService';then
    echo "FBO进程存在并且正在运行 ✔️"
else
    echo "FBO进程不存在 ❌"
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
TEMP_C=$(echo "scale=1; $BATTERY_TEMP / 10" | bc)
if (( $(echo "$TEMP_C <= 40.0" | bc -l) )); then
    echo "电池温度：目前温度$TEMP_C℃，未超过40.0℃ ✔️"
else
    echo "电池温度：目前温度$TEMP_C℃，超过40.0℃，无法触发FBO进程 ❌"
fi


usb_state=$(cat /sys/class/android_usb/android0/state)
if [ "$usb_state" = "DISCONNECTED" ]; then
    echo "电脑连接：未连接到电脑 ✔️"
else
    echo "电脑连接：已连接到电脑，无法触发FBO进程 ❌"
fi

SCREEN_STATUS=$(dumpsys power | grep mScreenOn=true)
if [ -z "$SCREEN_STATUS" ]; then
    echo "屏幕状态：屏幕已亮起，无法触发FBO进程 ❌"
else
    echo "屏幕状态：屏幕未亮起 ✔️"
fi

BATTERY_LEVEL=$(dumpsys battery | grep level | awk '{print $2}')
if [ $BATTERY_LEVEL -gt 75 ]; then
    echo "电量状态：目前电量$BATTERY_LEVEL，电量高于75% ✔️"
else
    echo "电量状态：目前电量$BATTERY_LEVEL，电量低于75%，无法触发FBO进程 ❌"
fi