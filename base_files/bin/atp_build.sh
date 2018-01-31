#!/bin/bash
usage()
{
    echo "$0 {-h} {-e} {-r g[debug os]}"
    echo " -h: help"
    echo " -c: compile atp,it will rebuild the out"
    echo " -r: run d/g"
    echo " -k: kill the dead process of atlaspeak"
	echo " -G:debug qemu"
    echo " -e: compile qemu"
    echo " defalut: compile project"
    exit 0
}

if [ -n "$PROJECT_PATH"]
then
    PROJECT_PATH=`pwd`
    echo "PROJECT_PATCH is $PROJECT_PATH"
else
    echo "PROJECT_PATH is $PROJECT_PATH"
fi

emulator_path=$PROJECT_PATH/out/emulator
echo "emulator_path="$emulator_path

debug_opt=
#dpy_opts="-nographic"
dpy_opts="-sdl -skin $emulator_path/qemu_skin/skin.xml -name CRB"
mid=

#Some vals
debug_qemu_init()
{
    firmware_path=$PROJECT_PATH/out/firmware
    # parse the image location info
    echo export firmware_path=$firmware_path
    export firmware_path=$firmware_path

    factory_name=factory/crb_v2/factory_data.bin
    factory_addr=0xffffe000
    factory_len=0x200
    echo export factory=$factory_name:$factory_addr:$factory_len
    export factory=$factory_name:$factory_addr:$factory_len

    product_name=factory/crb_v2/factory_data_product.bin
    product_addr=0xffffe200
    product_len=0x200
    echo export product=$product_name:$product_addr:$product_len
    export product=$product_name:$product_addr:$product_len

    data_name=emulator_data.bin
    #data_addr=0x4005c000
    #ATP2.0
    data_addr=0x401c4000
    data_len=0x4000
    echo export data=$data_name:$data_addr:$data_len
    export data=$data_name:$data_addr:$data_len

    arc_name=`cat $firmware_path/flash_arc_apps.cfg|grep load_image|awk '{print $2}'`
    arc_addr=`cat $firmware_path/partition.conf|grep arc_start_addr|sed 's/.*expr //g'|sed 's/ \]//g'`
    arc_addr=`python -c "print \"0x%x\"%($arc_addr)"`
    arc_len=`python -c "print \"0x%x\"%($data_addr - $arc_addr)"`
    echo export arc=$arc_name:$arc_addr:$arc_len
    export arc=$arc_name:$arc_addr:$arc_len

    quark_name=`cat $firmware_path/flash_x86_apps.cfg|grep load_image|awk '{print $2}'`
    quark_addr=`cat $firmware_path/partition.conf|grep quark_start_addr|sed 's/.*expr //g'|sed 's/ \]//g'`
    quark_addr=`python -c "print \"0x%x\"%($quark_addr)"`
    quark_len=`python -c "print \"0x%x\"%($arc_addr- $quark_addr)"`
    echo export quark=$quark_name:$quark_addr:$quark_len
    export quark=$quark_name:$quark_addr:$quark_len

    bootloader_name=`cat $firmware_path/flash_x86_bootloader.cfg|grep load_image|awk '{print $2}'`
    bootloader_addr=`cat $firmware_path/partition.conf|grep boot_start_addr|sed 's/.*expr //g'|sed 's/ \]//g'`
    bootloader_addr=`python -c "print \"0x%x\"%($bootloader_addr)"`
    bootloader_len=`python -c "print \"0x%x\"%($quark_addr - $bootloader_addr)"`
    echo export bootloader=$bootloader_name:$bootloader_addr:$bootloader_len
    export bootloader=$bootloader_name:$bootloader_addr:$bootloader_len

    rom_name=`cat $firmware_path/flash_x86_rom.cfg|grep load_image|awk '{print $2}'`
    rom_addr=`cat $firmware_path/partition.conf|grep rom_start_addr|sed 's/.*expr //g'|sed 's/ \]//g'`
    rom_addr=`python -c "print \"0x%x\"%($rom_addr)"`
    rom_len=`stat -L -c %s $firmware_path/$rom_name`
    rom_len=`python -c "print \"0x%x\"%($rom_len)"`
    echo export rom=$rom_name:$rom_addr:$rom_len
    export rom=$rom_name:$rom_addr:$rom_len

    mid=$(awk 'BEGIN{srand();print int(rand()*1000000+1000)}')
    echo "multi-instance id" $mid
    mkdir -p $emulator_path/multiinst_$mid
    self=$emulator_path/multiinst_$mid
    touch $self/x86_$PPID
	echo "self="$self
	echo "mid="$mid
}


create_gdb1_file()
{
cat >$PROJECT_PATH/debug-qemu-code.gdb <<EOF
 set args -m 32 -cpu qemu32 -M crb_x86 -no-reboot $dpy_opts -net none -clock dynticks -no-acpi -balloon none -no-hpet -nodefaults -serial pty -serial mon:stdio -no-kvm -mid $mid
c
EOF
}

rm_gdb1_file()
{
	rm -rf $PROJECT_PATH/debug-qemu-code.gdb
}

compile_atlaspeak()
{
	if [ ! -d "$PROJECT_PATH/out" ]; then
		echo "build the new out dir"
	fi
	make  -f $PROJECT_PATH/wearable_device_sw/internal/projects/curie_iq_crb/Makefile setup package OUT=$PROJECT_PATH/out -j12;
	#else
	#    make  -f $PROJECT_PATH/out/Makefile package -j12;

}

run_emulator()
{
	sh $PROJECT_PATH/out/emulator/emulator_crb.sh $debug_opt -w $PROJECT_PATH/out/firmware 2>&1
}

compile_emu()
{
	make  -f $PROJECT_PATH/Makefile emulator -j12 2>/dev/null

}

run_debug_by_gdb()
{
	gnome-terminal -t "gdb (DEBUG_QEMU)" -x bash -c "gdb $PROJECT_PATH/out/emulator/emulator_x86  -x $PROJECT_PATH/debug-qemu-code.gdb; exec bash;"
	#gnome-terminal -t "gdb (DEBUG_QEMU)" -x bash -c "$PROJECT_PATH/out/emulator/emulator_x86 -m 32 -cpu qemu32 -M crb_x86 -no-reboot $dpy_opts -net none -clock dynticks -no-acpi -balloon none -no-hpet -nodefaults -serial pty -serial mon:stdio -no-kvm -mid $mid ;exec bash;"

	sleep 1

	sensor_file=$emulator_path/emulator_sensor_ble.trace
	$emulator_path/emulator_sensor_file $self/chr_curie_bmi160 $self/chr_curie_bmi150 $sensor_file 2>/dev/null&
	echo touch $self/emulator_sensor_file_$!
	touch $self/emulator_sensor_file_$!

	#$emulator_path/emulator_arc.sh -M crb_arc  -i $mid
	$emulator_path/emulator_arc -m 32 -cpu arcem4 -M crb_arc -no-reboot -nographic -net none -clock dynticks -balloon none -nodefaults -serial pty -serial mon:stdio -no-kvm -mid $mid
	rm_gdb1_file;
}

kill_atp()
{
	ps aux|grep emulator|awk '{print $2}'|xargs -i kill -9 {}
}

while getopts ":hkcr:eG"  opt
do
    case "$opt" in
        h)
            usage;
            ;;
		c)
			compile_atlaspeak
			;;
        r)
            if [ "$OPTARG" = "g" ]
            then
				debug_qemu_init
				echo "Debug the guest OS"
                debug_opt="-g"
            fi
			run_emulator;
			;;
		e)
			compile_emu;
            ;;
		k)
			kill_atp
			;;
        G)
			debug_qemu_init
			create_gdb1_file
			run_debug_by_gdb
           ;;

        ?)
            echo "unknow option:$opt"
            ;;
    esac
done

