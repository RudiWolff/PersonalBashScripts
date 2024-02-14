# Source : https://unix.stackexchange.com/questions/564013/script-does-not-run-commands-in-bluetoothctl
# You can use bluetoothctl command in shell script as follow :
# bluetoothctl -- command
# or :
# echo -e "command\n" | bluetoothctl
# e.g. :
# bluetoothctl -- connect XX:XX:XX:XX:XX:XX (MAC address of device)
# 
# script below works like a charm. 
# Its especially useful when adding "sleep" delays between 'pair', 'trust' and 'connect' under bluetoothctl 
# to give it time to discover and setup the BT devices.

#bluetoothctl -- power off
#bluetoothctl -- power on
#bluetoothctl -- scan on
##bluetooth -- scan off
#bluetoothctl -- remove F4:73:35:8B:23:A8
#gnome-terminal -- bluetoothctl
echo "Press and hold botton F1 3 seconds please."
sleep 5
bluetoothctl -- pair F4:73:35:8B:23:A8
bluetoothctl -- trust F4:73:35:8B:23:A8
bluetoothctl -- connect F4:73:35:8B:23:A8
