if [ "$(getprop init.svc.fbo-installd)" = "running" ]; then
    echo init_FBO正在运行😋
else
    echo init_FBO已停止😭
fi
if [ "$(getprop persist.sys.fboservice.ctrl)" = "true" ]; then
    echo FBO已启动😋
else
    echo FBO未开启😭
fi

if [ "$(getprop persist.sys.stability.miui_fbo_enable)" = "true" ]; then
    echo MIUI_FBO已启动😋
else
    echo MIUI_FBO未开启😭
fi
echo
if [ -f "/system_ext/etc/init/memory.fbo.native@1.0-service.rc" ]; then
    echo rc文件存在🥰
else 
    echo rc文件不存在😭
    echo 请查看目录/system_ext/etc/init/init确认memory.fbo.native@1.0-service.rc是否存在
    echo
fi

if [ -f "/system_ext/bin/FboNativeService" ]; then
    echo FboNativeService存在😋
else 
    echo FboNativeService不存在😭
    echo 请查看/system_ext/bin/下是否存在FboNativeService
fi
