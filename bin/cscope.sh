#!/bin/bash
#* is equal as $@
usage()
{
    echo "$0 {-h} {-d dir} {-R dir}"
    echo " -h: help"
    echo " -f: add files under new dir"
    echo " -F: add all files under dir recursivly"
    echo " -D: delete all files under dir recursivly"
    echo " -s: delete all files that contain the strings"
    echo " defalut: clear the old cscope_files,add all files under dir recursivly"
    exit 0

}

_clear_cs_files=1
_rm_tags=0
_recursive_all=1
B_STRINGS=

while getopts hfFDs: opt
do
    case "$opt" in
        h)
            usage;
            ;;
        f)
            _recursive_all=0
            _clear_cs_files=0;
           shift $((OPTIND - 1))
            ;;
        F)
            _recursive_all=1
            _clear_cs_files=0;
            shift $((OPTIND - 1))
            ;;
        D)
            _rm_tags=1
            _recursive_all=-1
            _clear_cs_files=0;
            shift $((OPTIND - 1))
            ;;
        s)
            B_STRINGS="$OPTARG"
            shift $((OPTIND - 1))
            ;;

        ?)
            exit 0;
            ;;
    esac
done

PWD_PATH=`pwd`

add_files_recursivly()
{
    if [ $_recursive_all -eq 0 ];then
        exit -1
    fi
#* is equal to the $@,every params will be considered as a string
    #for file in *
#Check that if there is the old cscope.files
    for file in `ls $PWD_PATH`
    do
        if [ -f $file ] && [ $file = "cscope.files" ] && [ $_clear_cs_files -eq 1 ]
        then
            echo "clear the cscope.files";
            echo > $PWD_PATH/cscope.files
            break;
        fi
    done

#Put the files name into the new cscope.files
    if [ $# -ne 0 ] ; then
        for i in $@;do
            echo "Add files recursivly:"`pwd`/$i
            find `pwd`/$i -name "*.cmd" -o  -name "*.c" -o -name "*.h" -o -name "Makefile" -o -name "*.go"  -o -name "*conf*" -o -name "*vpf" -o -name "*.S" -o -name "*.s" >> $PWD_PATH/cscope.files
        done
    else
        echo "Add:pwd="`pwd`
        find `pwd` -name "*.cmd" -o  -name "*.c" -o -name "*.h" -o -name "Makefile" -o -name "*.go"-o -name "*conf*" -o -name "*vpf" -o -name "*.S" -o -name "*.s" >> $PWD_PATH/cscope.files
    fi
}

add_files_under_dirs()
{
    for file in $@
    do
        if [ -f $file ] && [ $file = "cscope.files" ]
        then
            echo "can not be cscope.files"
            exit -1
        fi
    done

    if [ $# -ne 0 ] ; then
        for i in $@;do
            echo "Add files:"`pwd`/$i
            find `pwd`/$i -maxdepth 1 -name "*.cmd" -o  -name "*.c" -o -name "*.h" -o -name "Makefile" -o -name "*conf*" -o -name "*vpf" -o -name "*.S" -o -name "*.s" >> $PWD_PATH/cscope.files
        done
   fi
}


if [ $_recursive_all -eq 0 ]
then
    add_files_under_dirs $@
    ret=`echo $?`
    if [ $ret -eq -1 ]
    then
        echo "err exit"
        exit 0
    fi
elif [ $_recursive_all -eq 1 ]
then
    add_files_recursivly $@
    ret=`echo $?`
    if [ $ret -eq -1 ]
    then
        echo "err exit"
        exit 0
    fi
fi

#rm the tags
if [ $_rm_tags -eq 1 ]; then
    for i in $@
    do
        B_NAME=`basename $i`
        echo "bbb:$B_NAME"
        sed -i "/$B_NAME\//d"  $PWD_PATH/cscope.files
    done
    if [ -n "$B_STRINGS" ]
    then
        sed -i "/$B_STRINGS/d"  $PWD_PATH/cscope.files
    fi
fi

#Delete the repeat line
sort -u $PWD_PATH/cscope.files | tee $PWD_PATH/cscope.tmp >/dev/null 2>&1
mv $PWD_PATH/cscope.tmp $PWD_PATH/cscope.files
#Remove the space line
sed -i '/^$/d' $PWD_PATH/cscope.files
sed -i '/^[[:space:]]*$/d' $PWD_PATH/cscope.files

cscope -bkq -i $PWD_PATH/cscope.files
sync
if [ $_rm_tags -ne 1 ]
then
    ctags -R $@
fi

