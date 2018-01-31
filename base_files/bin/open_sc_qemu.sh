#!/bin/bash
#echo $(pwd)
cd $(pwd)
export LD_LIBRARY_PATH=/home/sherlock/workspace/ndg/sdk_atalspeak/intel-pvp:$LD_LIBRARY_PATH
/home/sherlock/workspace/ndg/sdk_atalspeak/qemu-arc/i386-softmmu/qemu-system-i386 -m 32 -cpu qemu32 -no-reboot -nographic -net none -clock dynticks -no-acpi -balloon none -no-hpet -nodefaults -no-kvm -kernel outdir/NODE1.elf -serial mon:stdio -serial tcp:127.0.0.1:4444,server -serial tcp:127.0.0.1:4445,server,wait  

