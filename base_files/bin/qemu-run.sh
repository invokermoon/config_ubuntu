#!/bin/bash

usage()
{
    echo "$0 {-h} {--kernel bin_file} {--rootfs rootfs} {-g ELF_file}"
    echo "**********************************************************************************************"
    echo "eg:qemu-run.sh --kernel ./linux-4.4/arch/x86/boot/bzImage --rootfs rootfs.img"
    echo "If we want to debug guest OS:"
    echo "eg:qemu-run.sh --kernel ./linux-4.4/arch/x86/boot/bzImage --rootfs rootfs.img -g GUEST_OS_ELF"
    echo "If we want to debug qemu code:"
    echo "eg:qemu-run.sh --kernel ./linux-4.4/arch/x86/boot/bzImage -G"
    echo "**********************************************************************************************"
    echo " -h: help"
    echo " --kernel: run the kernel.bin"
    echo " --rootfs: run the rootfs"
    echo " -g/--gdb: gdb debug"
    echo "**********************************************************************************************"
    exit 0
}

rt_en=0
k_en=0
debug_guest_en=0
debug_qemu_en=0

#-o表示短选项，两个冒号表示该选项有一个可选参数，可选参数必须紧贴选项
#如-carg 而不能是-c arg
#--long表示长选项
#"$@"在上面解释过
# -n:出错时的信息
# -- ：举一个例子比较好理解：
#我们要创建一个名字为 "-f"的目录你会怎么办？
# mkdir -f #不成功，因为-f会被mkdir当作选项来解析，这时就可以使用
# mkdir -- -f 这样-f就不会被作为选项。

TEMP=`getopt -o hGg:k:f: --long ,gdb-guest:,kernel:,rootfs:,tst,gdb-qemu -- "$@"`


if [ $? != 0 ] ; then
    usage
    echo "Terminating..." >&2 ; exit 1 ;
fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true; do
  case "$1" in
    -h | --tst )
          usage;
          shift
          ;;
    -k | --kernel )
        k_en=1
        KERNEL_IMAGE=$2;
        echo "KERNEL_IMAGE is $KERNEL_IMAGE"
        shift 2;;
    -f | --rootfs )
        rt_en=1
        ROOTFS_IMAGE=$2;
        echo "rootfs is $ROOTFS_IMAGE"
        shift 2;;
    -g | --gdb-guest )
        echo "gggg"
        debug_guest_en=1
        guest_dbg_opts="-s -S"
        GUEST_OS_ELF_FILE="$2"; shift 2 ;;
    -G | --gdb-qemu )
        debug_qemu_en=1
        echo "GGGGG"
        shift
        ;;
    -- )
        shift; break ;;
    * )
        echo "Unknow options"
        break ;;
  esac
done

ABS_PATH=`pwd`
TEMP_QEMU_ELF=${QEMU_ELF:=qemu-system-i386}
echo "TEMP_QEMU_ELF=$TEMP_QEMU_ELF"

check_env()
{
    if [ ! -f "$KERNEL_IMAGE" ]; then
        echo "ERROR:Please input the right KERNEL_IMAGE"
        exit -1;
    fi
    if [ ! -f "$ROOTFS_IMAGE" ]; then
        echo "WARNING:No rootfs.img"
    fi
#   for file in `ls | find ./ -name qemu-system-i386`
#   do
#       if [ ! -f "$file" ]; then
#           echo "WARNING:Please input the qemu_elf file"
#       else
#           QEMU_ELF=$file
#           echo "QEMU_ELF=$QEMU_ELF"
#       fi
#   done
}

check_env;

cat > $ABS_PATH/debug_guest_os.gdb <<EOF
set remotetimeout 120
target remote 127.0.0.1:1234
file $GUEST_OS_ELF_FILE
EOF

cat > $ABS_PATH/debug_qemu_os.gdb <<EOF
set args -M pc -kernel $KERNEL_IMAGE
file $TEMP_QEMU_ELF
EOF

if [ $debug_guest_en -eq 1 ]; then
    gnome-terminal -t "gdb (Guest OS)" -x bash -c "gdb -x $ABS_PATH/debug_guest_os.gdb; exec bash;"
fi
if [ $debug_qemu_en -eq 1 ]; then
    #gnome-terminal -t "gdb (QEMU OS)" -x bash -c "gdb $TEMP_QEMU_ELF -x $ABS_PATH/debug_qemu_os.gdb; exec bash;"
    gdb $TEMP_QEMU_ELF -x $ABS_PATH/debug_qemu_os.gdb
fi

if [ $k_en -eq 1 ] && [ $debug_qemu_en -ne 1 ]; then
    if [ $rt_en -eq 1 ]; then
        echo "starting qemu -kernel -rootfs"
        $TEMP_QEMU_ELF -M pc -kernel $KERNEL_IMAGE -initrd $ROOTFS_IMAGE $guest_dbg_opts
    else
        echo "starting qemu only with kernel"
        $TEMP_QEMU_ELF -M pc -kernel $KERNEL_IMAGE $guest_dbg_opts
    fi
fi

#Common command
#qemu-system-i386 -m 32 -cpu qemu32 -no-reboot -nographic -net none -clock dynticks -no-acpi -balloon none -no-hpet -nodefaults -no-kvm -kernel $1 -serial mon:stdio $2 $3

# clean up
pid=`ps f | sort |grep qemu-system-i386 | awk '{print \$1}'`
echo "kill $pid"
kill $pid 2>/dev/null;
pid=`ps f | sort | grep debug_guest_os.gdb | awk '{print \$1}'`
echo "kill $pid"
kill $pid 2>/dev/null;
rm $ABS_PATH/debug_guest_os.gdb
rm $ABS_PATH/debug_qemu_os.gdb
