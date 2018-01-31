#!/bin/bash
echo "$1"
qemu-system-i386 -m 32 -cpu qemu32 -no-reboot -nographic -net none -clock dynticks -no-acpi -balloon none -no-hpet -nodefaults -no-kvm -kernel $1 -serial mon:stdio $2 $3
