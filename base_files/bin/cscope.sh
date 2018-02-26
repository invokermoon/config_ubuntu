#!/bin/bash
#* is equal as $@
color_none="\033[m"
color_red="\033[0;32;31m"
color_LIGHT_RED="\033[1;31m"
color_green="\033[0;32;32m"
color_blue="\033[0;32;34m"
color_brown="\033[0;33m"
color_yellow="\033[1;33m"
color_white="\033[1;37m"


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
find_types='-name "*.c" -o -name "*.cpp" -o -name "*.dtsi" -o -name "*.hpp" -o -name "*.h" -o -name "*.asm" -o -name "*.dts"'
find_types1='-name "*.cmd" -o  -name "*.c" -o -name "*.cpp" -o -name "*.java" -o -name "*.h" -o -name "Makefile" -o -name "*.go"  -o -name "*conf*" -o -name "*vpf" -o -name "*.S" -o -name "*.s"'
git_types=".c$|.cpp$|.h$|.hpp$"
git_branch=master

PWD_PATH=`pwd`


flag_clear_tagsfile=1
flag_rm_filestags=0
_max_dirdepth=
match_strings=

tags_dir="$PWD_PATH/.tags_dir"
reference_tagsfile="$tags_dir/gtags.files"


while getopts hfFDs: opt
do
    case "$opt" in
        h)
            usage;
            ;;
        f)
            _max_dirdepth='-maxdepth 1'
            flag_clear_tagsfile=0;
           shift $((OPTIND - 1))
            ;;
        F)
            _max_dirdepth=
            flag_clear_tagsfile=0;
            shift $((OPTIND - 1))
            ;;
        D)
            flag_rm_filestags=1
            _max_dirdepth=
            flag_clear_tagsfile=0;
            shift $((OPTIND - 1))
            ;;
        s)
            match_strings="$OPTARG"
            shift $((OPTIND - 1))
            ;;

        ?)
            exit 0;
            ;;
    esac
done


pre_check()
{
    if [ ! -d "$tags_dir" ]; then 
        echo "[+] Create the $tags_dir";
        mkdir -p $tags_dir
    fi
    if [ ! -f "$reference_tagsfile" ]; then 
        echo "[+] Create the $reference_tagsfile";
        eval echo >$reference_tagsfile
    fi

}

add_files()
{
    #Check that if there is the old $reference_tagsfile
    if [ -f $reference_tagsfile ] && [ $flag_clear_tagsfile -eq 1 ]; then
        echo "[+] Clear the $reference_tagsfile";
        echo >$reference_tagsfile
    fi

    #Put the files name into the new $reference_tagsfile
    if [ $# -ne 0 ]; then
        for i in $@; do
            #use git tree
            if [ -d $i ] && [ $i = ".git" ]; then
                echo -e "$color_red[Please input the right git branch]$color_white"
                read git_branch
                echo -e $color_green"[+] Add [.git][$git_branch] recursivly:"$color_none`pwd`/$i
                git ls-tree -r --name-only $git_branch | egrep $git_types | egrep -v $ignore_targets >>$reference_tagsfile
                break;
            else
                echo -e $color_green"[+] Add [DIRS] [maxdepth:$maxdepth]:"$color_none`pwd`/$i
                eval find $PWD_PATH/$i $_max_dirdepth -type f $find_types | egrep -sv $ignore_targets >>$reference_tagsfile
            fi
        done
    else
        echo "[+] Add [pwd] recursivly:"`pwd`
        eval find `pwd` $find_types >> $reference_tagsfile
    fi
}

rm_files()
{
    #rm the file tags
    if [ $flag_rm_filestags -eq 1 ]; then
        for i in $@
        do
            #B_NAME=`basename $i`
            B_NAME="$i"
            temp_full_name=`echo $B_NAME | sed 's#\/#\\\/#g'`
            echo "[+] remove_tags:$B_NAME"
            sed -i "/$temp_full_name/d"  $reference_tagsfile
        done
        if [ -n "$match_strings" ]
        then
            echo "[+] remove Strings:$match_strings"
            sed -i "/$match_strings/d"  $reference_tagsfile
        fi
    fi
}

sort_target_file()
{
    sort_file=
    if [ $# -eq 1 ]; then
        sort_file=$1
    else
        sort_file=$reference_tagsfile
    fi
    echo -e $color_brown"[+] sort the file:"$color_none$sort_file
    #Delete the repeat line
    sort -u $sort_file | tee $tags_dir/reference_tagsfile.tmp >/dev/null 2>&1
    mv $tags_dir/reference_tagsfile.tmp $sort_file
    #Remove the space line
    sed -i '/^$/d' $sort_file
    sed -i '/^[[:space:]]*$/d' $sort_file
}

populate_file_list()
{
    printf "[+] Populating file list...\n"

    if [ $flag_rm_filestags -eq 0 ]; then
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

    sort_target_file $reference_tagsfile

    printf "[+] Populating files OK...\n"
}

build_global()
{
    #printf "[+]$color_yellow Show the Gnu-global env:$color_LIGHT_RED\n"
    #gtags --config
    printf "$color_green[+] Building GNU Global database...\n"
    #gtags -f $reference_tagsfile $tags_dir --accept-dotfiles
    gtags -f $reference_tagsfile $tags_dir --accept-dotfiles
    #cp -pf GPATH GRTAGS GTAGS $tags_dir 2>/dev/null
}

#如果需要#if 0里面的定义，可以–if0=yes来忽略 #if 0这样的定义。
build_ctags()
{
    #printf "[+]$color_yellow Show the ctags env:$color_LIGHT_RED\n"
    #ctags --list-languages
    #ctags --list-maps
    printf "$color_white[+] Building ctags database...\n"
    #ctags -L $reference_tagsfile
    #ctags  -a -R --langmap=c++:+.c   --c++-kinds=+p  --fields=+iaKSz --extra=+q -L $reference_tagsfile
    ctags  -a --fields=+iaKSz -L $reference_tagsfile
    #ctags -I __THROW -I __attribute_pure__ -I __nonnull -I __attribute__ -I inline --file-scope=yes --langmap=c:+.h --languages=c,c++,java,python --links=yes --c-kinds=+p --c++-kinds=+p --fields=+iaS --extra=+q -L $reference_tagsfile
    #ctags -R --fields=+iaS --extra=+q  $@
}

build_cscope()
{
#    printf "[+] Quoting file paths...\n"
#    sed -i 's/^/"/;s/$/"/' $reference_tagsfile
    printf "[+] Building cscope database...\n"
    cscope -vbq -i $reference_tagsfile -f $tags_dir/cscope.out

}

main()
{
    pre_check

    populate_file_list $@
    #build_ctags
    build_global

    #build_cscope

    #printf "[+] Moving global database files...\n"
    #mv -f $PWD_PATH/{GTAGS,GPATH,GRTAGS} .

    #printf "[+] Moving cscope database files...\n"
    #mv -f $tags_dir/{cscope.out,cscope.out.in,cscope.out.po} .
}

main $*

