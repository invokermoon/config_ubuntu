#!/bin/bash
#some gloable config
flag=0
channel1=0
channel2=0

PASSWD=0
bTmac=04:18:0F:37:A1:4E
#bTmac=20:6E:9C:F1:B2:F2
#bTmac=B0:DF:3A:65:E4:BF


name1=zyf_hello_in
name2=zyf_hello_out
tcp="tcp"
twostd="2std"
onestd="std"
testone="testone"
testfwsc="testfwsc"
tcpsc="tcpsc"
if [ $# -ne 1 ]
then
    echo "[error]:err cmd,pls add a param,like:tcp,,std,2std,tcpsc,testfwsc"
    exit 0;
fi

sdptool browse $bTmac > .t1t.txt
sync
cat .t1t.txt

while read line
do
	echo $line | grep "$name1"
	ret=$?
	echo $line | grep "$name2"
	ret1=$?
	if [ $ret -eq 0 ] || [ $ret1 -eq 0 ]
	then
		flag=1
    fi

	if [ $flag -eq 1 ]
	then
		echo $line | grep Channel
		if [ $? -eq 0 ]
		then
			echo $line | cut -d ' ' -f2
			if [ $channel1 -eq 0 ]
			then
				channel1=`echo $line | cut -d ' ' -f2`
			else
				channel2=`echo $line | cut -d ' ' -f2`
			fi
			flag=0
		fi
	fi
done < .t1t.txt
#if [ $channel1 -eq 0 ]
#then
#    echo "cant find the $name1"
#elif [ $channel2 -eq 0 ]
#then
#    echo "cant find the $name2"
#fi

if [ $channel1 -eq 0 ] && [ $channel2 -eq 0 ] && [ "$1" != "$testone"  ] &&  [ "$1" != "testfwsc" ]
then
    echo "[error]:cant find any socket name,pls run download the app first"
    exit 0;
fi

#release the rfcomm
echo $PASSWD | sudo -S rfcomm release /dev/rfcomm0
echo $PASSWD | sudo -S rfcomm release /dev/rfcomm1 
#echo $PASSWD | sudo -S rfcomm connet /dev/rfcomm0 $bTmac $channel1&
#sleep 2
#echo $PASSWD | sudo -S rfcomm connet /dev/rfcomm1 $bTmac $channel2&
#sleep 2

if [ "$1" = "$tcp" ];
then
    echo "tcp socket start"
    sleep 1
    echo $PASSWD | sudo -S rfcomm connet /dev/rfcomm0 $bTmac $channel1&
    sleep 2
    echo $PASSWD | sudo -S rfcomm connet /dev/rfcomm1 $bTmac $channel2&
    sleep 1

    #open fw_NODE
    gnome-terminal -t "FW_NODE_QEMU" -x bash -c "sh ~/bin/open_fw_qemu.sh;exec bash;"
    echo "[info]socat the fw_node and sc_node"
    sleep 1

    echo "[info] open the sc_node_qemu"
    gnome-terminal -t "SC_NODE_QEMU" -x bash -c "sh ~/bin/open_sc_qemu.sh;exec bash;"
 
    echo "[info]before socat ,please opne the qemu-terminal"
    sleep 2
    echo $PASSWD | sudo socat tcp4:127.0.0.1:4444 tcp4:127.0.0.1:4447&
   # echo $PASSWD | sudo socat  -  tcp4:127.0.0.1:4444&
   # echo $PASSWD | sudo socat /dev/rfcomm1,raw tcp4:127.0.0.1:4444&
    sleep 2
    echo $PASSWD | sudo socat /dev/rfcomm0  tcp4:127.0.0.1:4445&
    #echo $PASSWD | sudo socat /dev/rfcomm0,raw tcp4:127.0.0.1:4445&
    sleep 1
    echo $PASSWD | sudo socat -x /dev/rfcomm1 tcp4:127.0.0.1:14444& 
    echo "tcp socket end"

elif [ "$1" = "testfwsc" ];
then
    echo "fw and sc connect start"
  #open fw_NODE
    gnome-terminal -t "FW_NODE_QEMU" -x bash -c "sh ~/bin/open_fw_qemu.sh;exec bash;"

    echo "[info] open the sc_node_qemu"
    gnome-terminal -t "SC_NODE_QEMU" -x bash -c "sh ~/bin/open_sc_qemu.sh;exec bash;"
#gnome-terminal -x qemu-system-i386 -m 32 -cpu qemu32 -no-reboot -nographic -net none -clock dynticks -no-acpi -balloon none -no-hpet -nodefaults -no-kvm -kernel outdir/NODE1.elf -serial mon:stdio -serial tcp:127.0.0.1:4444,server -serial tcp:127.0.0.1:4445,server,wait
    echo "[info]before socat ,please opne the qemu-terminal"
   sleep 1
    echo "[info]socat the fw_node and sc_node"
    echo $PASSWD | sudo -S sudo socat tcp4:127.0.0.1:4444  tcp4:127.0.0.1:4447&

   # echo $PASSWD | sudo -S gnome-terminal -t "TCP444" -x sudo socat -,raw tcp4:127.0.0.1:4444&
    echo $PASSWD | sudo -S gnome-terminal -t "TCP445" -x sudo socat -,raw tcp4:127.0.0.1:4445&

    #sleep 1
   # echo $PASSWD | sudo -S gnome-terminal -t "TCP446" -x sudo socat -,raw tcp4:127.0.0.1:4446&
    echo "socket end"

elif [ "$1" = "tcpsc" ];
then
    echo "2 tcp sc start"
    echo $PASSWD | sudo -S rfcomm connet /dev/rfcomm0 $bTmac $channel1&
    sleep 1
    echo $PASSWD | sudo -S rfcomm connet /dev/rfcomm1 $bTmac $channel2&
    sleep 1
    echo "[info] open the sc_node_qemu"
    gnome-terminal -t "SC_NODE_QEMU" -x bash -c "sh ~/bin/open_sc_qemu.sh;exec bash;"
#gnome-terminal -x qemu-system-i386 -m 32 -cpu qemu32 -no-reboot -nographic -net none -clock dynticks -no-acpi -balloon none -no-hpet -nodefaults -no-kvm -kernel outdir/NODE1.elf -serial mon:stdio -serial tcp:127.0.0.1:4444,server -serial tcp:127.0.0.1:4445,server,wait
    echo "[info]before socat ,please opne the qemu-terminal"
    sleep 1
   # echo $PASSWD | sudo socat -  tcp4:127.0.0.1:4444&
    echo $PASSWD | sudo -S gnome-terminal -t "TCP444" -x sudo socat -,raw tcp4:127.0.0.1:4444&
    sleep 1
    echo $PASSWD | sudo socat /dev/rfcomm0  tcp4:127.0.0.1:4445&
   # sleep 1 
   # echo $PASSWD | sudo socat -  tcp4:127.0.0.1:4446&
    sleep 1
    echo $PASSWD | sudo socat -x /dev/rfcomm1 tcp4:127.0.0.1:14444& 
    sleep 1
    echo "2 tcp sc end"


elif [ "$1" = "$testone" ];
then
    echo "test by std"
    sleep 2
    gnome-terminal -t "NODE" -x bash -c "sh ~/bin/open_sc_qemu.sh;exec bash;"
#gnome-terminal -x qemu-system-i386 -m 32 -cpu qemu32 -no-reboot -nographic -net none -clock dynticks -no-acpi -balloon none -no-hpet -nodefaults -no-kvm -kernel outdir/NODE1.elf -serial mon:stdio -serial tcp:127.0.0.1:4444,server -serial tcp:127.0.0.1:4445,server,wait
    echo "before socat ,please opne the qemu-terminal"
    sleep 2
    sleep 2
    echo $PASSWD | sudo -S gnome-terminal -t "TCP444" -x sudo socat -,raw tcp4:127.0.0.1:4444&
    sleep 2
    echo $PASSWD | sudo -S gnome-terminal -t "TCP445" -x sudo socat -,raw tcp4:127.0.0.1:4445&
    #sleep 1
   # echo $PASSWD | sudo -S gnome-terminal -t "TCp446" -x sudo socat -,raw tcp4:127.0.0.1:4446&
    sleep 1
    echo $PASSWD | sudo -S gnome-terminal -t "TCP14444" -x sudo socat -,raw tcp4:127.0.0.1:14444&
    echo "test end"
elif [ "$1" = "$twostd" ];
then
    echo "two std console start"
    echo $PASSWD | sudo -S rfcomm connet /dev/rfcomm0 $bTmac $channel1&
    sleep 2
    echo $PASSWD | sudo -S rfcomm connet /dev/rfcomm1 $bTmac $channel2&
    sleep 2
    echo "before socat ,please opne the qemu-terminal"
    echo $PASSWD | sudo -S gnome-terminal -x sudo socat /dev/rfcomm1,raw -&
    sleep 2
    echo $PASSWD | sudo -S gnome-terminal -x sudo socat /dev/rfcomm0,raw -&
    echo "two std console end"
elif [ "$1" = "$onestd" ];
then
    echo "one std console start"
    echo $PASSWD | sudo -S rfcomm connet /dev/rfcomm1 $bTmac $channel2&
    sleep 2
    echo "before socat ,please opne the qemu-terminal"
    echo $PASSWD | sudo -S gnome-terminal -x sudo socat /dev/rfcomm1,raw -&
    echo "one std console end"
else
    echo "err cmd"
fi
#echo $PASSWD | sudo -S socat /dev/rfcomm0,raw $addr2
