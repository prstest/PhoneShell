#View kernel
echo "Phone model：$(getprop ro.product.bootimage.model)"
echo "Android Version：$(getprop ro.build.version.release)"
echo "Secure patch：$(getprop ro.build.version.security_patch)"
echo "Kernel Version：$(uname -r)"
echo "Kernel framework：$(uname -s) $(uname -m)"
echo "Kernel information：$(cat /proc/version | cut -d'(' -f3 | cut -d')' -f1)"
echo "Compile time: $(uname -v)"
echo "Processor：$(cat /proc/cpuinfo | grep -m1 "Hardware" | cut -d':' -f2 | sed 's/^[ \t]*//')"
echo "ZRAM size："$(awk 'NR > 1 {size=$3/(1024*1024); printf "%.1fG\n", size}' /proc/swaps)
package_name1="me.weishu.kernelsu"
package_name2="cn.myflv.noactive"
if pm list packages | grep -qw "$package_name1"; 
then
    echo "Root environment：KernelSU"
fi
echo "The root module you have"
find /data/adb/modules/ -name 'module.prop' -exec awk -F= '/^name=/ {name=$2} /^version=/ {print "😋", name, "" $2 ""}' {} +
echo " "

# View bettery  
# spreader：Rock&Z
charge_full=`su -c cat /sys/class/power_supply/battery/charge_full`
charge_full_design=`su -c cat /sys/class/power_supply/battery/charge_full_design`
cycle_count=`su -c cat /sys/class/power_supply/battery/cycle_count`
echo "Bettery design capactity：$(echo "scale=0;$charge_full_design/1000"|bc)mAh"
echo "Loop Count：$cycle_count"
echo "Bettery current full：$(echo "scale=0;$charge_full/1000"|bc)mAh"
JKD=$(echo "100*$charge_full/$charge_full_design"|bc)
echo "Current bettery health degree：$JKD%"
echo " "

# View Frozen status 
# author：JARK006
vers=$(head -n 1 /data/system/NoActive/log | awk '{print $NF}')
if pm list packages | grep -qw "$package_name2"; then
    echo "Tombstone environment：Noactive($vers)"
fi
if [ -e /sys/fs/cgroup/uid_0/cgroup.freeze ]; then
    echo "✔️Mounted FreezerV2(UID)"
fi

if [ -e /sys/fs/cgroup/freezer/perf/frozen/freezer.state ]; then
    echo "✔️Mounted FreezerV1(FROZEN)"
fi
v1Info=$(mount | grep freezer | awk '{print"✔️Mounted FreezerV1:",$3}')
if [ ${#v1Info} -gt 2 ]; then
    echo "$v1Info"
fi

status=$(ps -A | grep -E "refrigerator|do_freezer|signal" | awk '{print $6 " " $9}')
status=${status//"__refrigerator"/"😴 FreezerV1 Frozening:"}
status=${status//"do_freezer_trap"/"😴 FreezerV2 Frozening:"}
status=${status//"do_signal_stop"/"😴 GSTOPFrozening:"}

if [ ${#status} -gt 2 ]; then
echo "==============[ Frozen status ]==============
$status"
else
    echo "Not Frozen process"
fi