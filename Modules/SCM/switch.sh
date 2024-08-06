input="/sys/class/power_supply/battery/input_suspend"
if [ $(cat $input) -eq 0 ]; then
 echo 1 > $input
else
 echo 0 > $input
fi