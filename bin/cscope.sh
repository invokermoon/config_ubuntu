#!/bin/bash
#* is equal as $@
color_NONE="\033[m"
color_RED="\033[0;32;31m"
color_LIGHT_RED="\033[1;31m"
color_GREEN="\033[0;32;32m"
color_BLUE="\033[0;32;34m"
color_BROWN="\033[0;33m"
color_YELLOW="\033[1;33m"
color_WHITE="\033[1;37m"


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

ignore_targets="bin|tools"
#find_types="\( -name \*.c -o -name \*.cpp -o -name \*.cc -o -name \*.hpp -o -name \*.h -o -name \*.asm -o -name \*.def \)"
find_types='-name "*.c" -o -name "*.cpp" -o -name "*.cc"-o -name "*.hpp" -o -name "*.h" -o -name "*.asm" -o -name "*.def"'
find_types1='-name "*.cmd" -o  -name "*.c" -o -name "*.cpp" -o -name "*.java" -o -name "*.h" -o -name "Makefile" -o -name "*.go"  -o -name "*conf*" -o -name "*vpf" -o -name "*.S" -o -name "*.s"'
git_types=".c$|.cpp$|.h$|.hpp$"
git_branch=master

PWD_PATH=`pwd`


_clear_cs_files=1
_rm_files_tags=0
_max_dirdepth=
B_STRINGS=

while getopts hfFDs: opt
do
    case "$opt" in
        h)
            usage;
            ;;
        f)
            _max_dirdepth='-maxdepth 1'
            _clear_cs_files=0;
           shift $((OPTIND - 1))
            ;;
        F)
            _max_dirdepth=
            _clear_cs_files=0;
            shift $((OPTIND - 1))
            ;;
        D)
            _rm_files_tags=1
            _max_dirdepth=
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

add_files()
{
#* is equal to the $@,every params will be considered as a string
    #for file in *
#Check that if there is the old cscope.files
    for file in `ls $PWD_PATH`
    do
        if [ -f $file ] && [ $file = "cscope.files" ] && [ $_clear_cs_files -eq 1 ]
        then
            echo "[+] clear the $PWD_PATH/cscope.files";
            echo > $PWD_PATH/cscope.files
            break
        fi
    done

#Put the files name into the new cscope.files
#If we input the target dir
    if [ $# -ne 0 ] ; then
        for i in $@;do
            if [ -d $i ] && [ $i = ".git" ]; then
                echo -e "\033[31m[Please input the right git branch]\033[0m"
                read git_branch
                echo -e $color_GREEN"[+] Add [.git][$git_branch] recursivly:"$color_NONE`pwd`/$i
                git ls-tree -r --name-only $git_branch | egrep $git_types | egrep -v $ignore_targets >>$PWD_PATH/cscope.files
            else
                echo -e $color_GREEN"[+] Add [DIRS] [maxdepth:$maxdepth]:"$color_NONE`pwd`/$i
                eval find $PWD_PATH/$i $_max_dirdepth -type f $find_types | egrep -sv $ignore_targets >>$PWD_PATH/cscope.files
            fi
        done
    else
        echo "[+] Add [pwd] recursivly:"`pwd`
        eval find `pwd` $find_types >> $PWD_PATH/cscope.files
    fi
}

rm_files()
{
    #rm the file tags
    if [ $_rm_files_tags -eq 1 ]; then
        for i in $@
        do
            #B_NAME=`basename $i`
            B_NAME="$i"
            temp_full_name=`echo $B_NAME | sed 's#\/#\\\/#g'`
            echo "[+] remove_tags:$B_NAME"
            sed -i "/$temp_full_name/d"  $PWD_PATH/cscope.files
        done
        if [ -n "$B_STRINGS" ]
        then
            echo "[+] remove Strings:$B_STRINGS"
            sed -i "/$B_STRINGS/d"  $PWD_PATH/cscope.files
        fi
    fi
}

#add_curdir_files()
#{
#    for file in $@
#    do
#        if [ -f $file ] && [ $file = "cscope.files" ]
#        then
#            echo "can not be cscope.files"
#            exit -1
#        fi
#    done
#
#    if [ $# -ne 0 ] ; then
#        for i in $@;do
#            echo "Add files:"`pwd`/$i
#            find `pwd`/$i -maxdepth 1 -name "*.cmd" -o  -name "*.c" -o -name "*.cpp"  -o -name "*.java" -o -name "*.h" -o -name "Makefile" -o -name "*conf*" -o -name "*vpf" -o -name "*.S" -o -name "*.s" >> $PWD_PATH/cscope.files
#        done
#   fi
#}
#

sort_target_file()
{
    sort_file=
    if [ $# -eq 1 ];then
        sort_file=$1
    else
        sort_file=$PWD_PATH/cscope.files
    fi
    echo -e $color_BROWN"[+] sort the file:"$color_NONE$sort_file
    #Delete the repeat line
    sort -u $sort_file | tee $PWD_PATH/cscope.tmp >/dev/null 2>&1
    mv $PWD_PATH/cscope.tmp $sort_file
    #Remove the space line
    sed -i '/^$/d' $sort_file
    sed -i '/^[[:space:]]*$/d' $sort_file
}

populate_file_list()
{
    printf "[+] Populating file list...\n"

    if [ $_rm_files_tags -eq 0 ]; then
        add_files $@
    else
        rm_files $@
    fi

    ret=`echo $?`
    if [ $ret -eq -1 ]
    then
        echo "err exit"
        exit 0
    fi

    sort_target_file $PWD_PATH/cscope_files

    printf "[+] Populating files OK...\n"
}

build_global()
{
    printf "[+] Building GNU Global database...\n"
    gtags -f $PWD_PATH/cscope.files $PWD_PATH
    cp -pf GPATH GRTAGS GTAGS $PWD_PATH 2>/dev/null
}

build_ctags()
{
    printf "[+] Building ctags database...\n"
    #ctags -L $PWD_PATH/cscope.files
    ctags  -a -R --langmap=c++:+.c   --c++-kinds=+p  --fields=+iaKSz --extra=+q -L $PWD_PATH/cscope.files
    #ctags -R --fields=+iaS --extra=+q  $@
}

build_cscope()
{
#    printf "[+] Quoting file paths...\n"
#    sed -i 's/^/"/;s/$/"/' $PWD_PATH/cscope.files

    printf "[+] Building cscope database...\n"
    cscope -vbq -i $PWD_PATH/cscope.files -f $PWD_PATH/cscope.out

}

main()
{

    populate_file_list $@
    build_global
    #build_ctags

    build_cscope

    #printf "[+] Moving global database files...\n"
    #mv -f $PWD_PATH/{GTAGS,GPATH,GRTAGS} .

    #printf "[+] Moving cscope database files...\n"
    #mv -f $PWD_PATH/{cscope.out,cscope.out.in,cscope.out.po} .
}

main $*

