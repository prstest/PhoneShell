if [ "$(getprop persist.sys.fboservice.ctrl)" = "true" ]; then
    echo FBO已启动😋
else
    echo FBO未开启😭
fi

if [ "$(getprop persist.sys.stability.miui_fbo_enable)" = "true" ]; then
    echo MIUI FBO已启动😋
else
    echo MIUI FBO未开启😭
fi
#setprop persist.sys.fboservice.ctrl true