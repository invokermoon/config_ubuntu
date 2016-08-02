#!/bin/bash
cd /home/sherlock/workspace/ndg/sdk_atalspeak/micro_framework
qemu-system-i386 -m 32 -cpu qemu32 -no-reboot -nographic -net none -clock dynticks -no-acpi -balloon none -no-hpet -nodefaults -no-kvm -kernel outdir/NODE1.elf -serial mon:stdio -serial tcp:127.0.0.1:4447,server,wait
