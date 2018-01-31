#!/bin/bash
color_none="\033[m"
color_red="\033[0;32;31m"
color_light_red="\033[1;31m"
color_green="\033[0;32;32m"
color_blue="\033[0;32;34m"
color_brown="\033[0;33m"
color_yellow="\033[1;33m"
color_white="\033[1;37m"

CUR_DIR=`pwd`
UPDATE_OUTPATH=$CUR_DIR/update_out
GITHUB_DIRS=("$CUR_DIR/base_files/bin" "$CUR_DIR/base_files/ssh")
SYSTEM_DIRS=("$HOME/bin" "$HOME/.ssh")

GITHUB_FILES=("$CUR_DIR/base_files/vimrc" "$CUR_DIR/base_files/gitconfig" "$CUR_DIR/base_files/bashrc")
SYSTEM_FILES=("$HOME/.vimrc" "$HOME/.gitconfig" "$HOME/.bashrc")

#md5 value that  recorded
ignore_checkfiles=$UPDATE_OUTPATH/ignore-check.files

github_files_num=${#GITHUB_FILES[@]}
system_files_num=${#SYSTEM_FILES[@]}
github_dirs_num=${#GITHUB_DIRS[@]}
system_dirs_num=${#SYSTEM_DIRS[@]}

DATE=`date +%F_%H:%M`
GITHUB_LOG=$UPDATE_OUTPATH/rsync-update.log

pre_checking()
{
    #if [ ${#GITHUB_FILES[*]} != ${#SYSTEM_FILES[@]} ]; then
    if [ $github_files_num != $system_files_num ]; then
        echo "PLease check the num of match files"$github_files_num"  "$system_files_num
        exit
    fi
    if [ $github_dirs_num != $system_dirs_num ]; then
        echo "PLease check the num of match dirs"$github_dirs_num"  "$system_dirs_num
        exit
    fi

    echo "Detecting files:"
    for ((i=0;i<$github_files_num;i++)) do
        if [ ! -f ${GITHUB_FILES[$i]} ]; then
            echo ""${GITHUB_FILES[$i]}" not exist"
            exit
        fi
        git diff ${GITHUB_FILES[$i]} ${SYSTEM_FILES[$i]} >/dev/null 2>&1
        if [ $? == 0 ]; then
            diff_status="SAME"
            echo -e "           $color_red[$diff_status]$color_green ${GITHUB_FILES[$i]} $color_white VS $color_green ${SYSTEM_FILES[$i]} $color_white"
        else
            diff_status="DIFF"
            echo -e "           $color_light_red[$diff_status]$color_green ${GITHUB_FILES[$i]} $color_white VS $color_green ${SYSTEM_FILES[$i]} $color_white"
        fi
        diff=`git diff ${GITHUB_FILES[$i]}`
        if [ ! -z "$diff" ]; then
            echo -e " $color_red Please commit ${GITHUB_FILES[$i]} $color_white "
            exit
        fi

    done
    echo "Detecting dirs:"
    for ((i=0;i<$github_dirs_num;i++)) do
        if [ ! -d ${SYSTEM_DIRS[$i]} ]; then
            mkdir -p ${SYSTEM_DIRS[$i]}
        fi

        if [ ! -d ${GITHUB_DIRS[$i]} ]; then
            echo "${GITHUB_DIRS[$i]} not exist"
            exit
        fi
        git diff ${GITHUB_DIRS[$i]} ${SYSTEM_DIRS[$i]} >/dev/null 2>&1
        if [ $? == 0 ]; then
            diff_status="SAME"
            echo -e "           $color_red[$diff_status]$color_green ${GITHUB_FILES[$i]} $color_white VS $color_green ${SYSTEM_FILES[$i]} $color_white"
        else
            diff_status="DIFF"
            echo -e "           $color_light_red[$diff_status]$color_green ${GITHUB_FILES[$i]} $color_white VS $color_green ${SYSTEM_FILES[$i]} $color_white"
        fi

        diff=`git diff ${GITHUB_DIRS[$i]}`
        if [ ! -z "$diff" ]; then
            echo -e " $color_red ${GITHUB_DIRS[$i]} has changed files $color_white "
            exit
        fi

    done
    if [ ! -d $UPDATE_OUTPATH ]; then
        mkdir -p $UPDATE_OUTPATH
    fi

    if [ ! -f $ignore_checkfiles ]; then
        echo "" >$ignore_checkfiles
    fi

}


diff_dirs()
{
    for ((i=0;i<$github_dirs_num;i++)) do
        md5file=`basename ${GITHUB_DIRS[$i]}`"-dir-rsync.md5"
        md5path=$UPDATE_OUTPATH/$md5file
        #if [ ! -f  "$md5path" ]; then
        find ${GITHUB_DIRS[$i]} -type f -exec md5sum {} \; >$md5path
        #fi
        for file in `find ${SYSTEM_DIRS[$i]} -type f`
        do
            ignore_ret=`grep $file $ignore_checkfiles`
            if [ -f $file ] && [ ! -n "$ignore_ret" ]; then
                tmp_md=$(md5sum $file)
                file_basename=`basename $file`
                grep $tmp_md $md5path >/dev/null 2>&1
                if  [ $? -gt 0 ]; then
                    echo -e "[$DATE] Update: $file ---> ${GITHUB_DIRS[$i]}/$file_basename \c"
                    while [ 1 ]; do
                        echo -e $color_green "[yes/no/check/ignore]$color_white[$color_red no ]$color_white\c"
                        read confirm
                        if [ "$confirm" = 'y'  ] || [ "$confirm" == 'Y'  ]; then
                            rsync -avzp $rfile  ${GITHUB_DIRS[$i]}/ >/dev/null
                            md5sum $file >> $md5path
                            #echo -e "Update $color_brown $file to ${GITHUB_DIRS[$i]}/$file_basename "$color_white"done"
                            printf "[$DATE][$color_green%-40.40s -----> %70.70s $color_white]===========>[$color_green ok $color_white]\n\n" $file ${GITHUB_DIRS[$i]}/$file_basename 
                        elif [ "$confirm" = 'c'  ] || [ "$confirm" == 'C'  ]; then
                            git diff $file ${GITHUB_DIRS[$i]}/$file_basename
                            continue;
                        elif [ "$confirm" = 'i'  ] || [ "$confirm" == 'I'  ]; then
                            echo "$file" >>$ignore_checkfiles
                        else
                            printf "[$DATE][$color_green%-40.40s -----> %70.70s $color_white]============>[$color_yellow ignore $color_white]\n\n" $file ${GITHUB_DIRS[$i]}/$file_basename 
                        fi
                        break
                    done
                fi
            fi
        done
    done
}

diff_files()
{
    for ((i=0;i<$github_files_num;i++)) do
        DIFF=`git diff ${GITHUB_FILES[$i]} ${SYSTEM_FILES[$i]}`
        if [ ! -z "$DIFF" ]; then
            #echo "${GITHUB_FILES[$i]} VS ${SYSTEM_FILES[$i]}" >>$GITHUB_LOG
            #git diff ${GITHUB_FILES[$i]} ${SYSTEM_FILES[$i]} >>$GITHUB_LOG
            while [ 1 ]; do
                echo -e "[$DATE] Update: ${SYSTEM_FILES[$i]} ---> ${GITHUB_FILES[$i]} \t$color_white\t$color_green[yes/no/check]$color_white[$color_red no ]$color_white\c"
                read confirm
                if [ "$confirm" = 'y'  ] || [ "$confirm" == 'Y'  ]; then
                    echo -e $color_blue"Copy: ${SYSTEM_FILES[$i]}  to ${GITHUB_FILES[$i]} "$color_white
                    printf "[$DATE][$color_green%-40.40s -----> %70.70s $color_white]============>[$color_green ok $color_white]\n\n" ${SYSTEM_FILES[$i]} ${GITHUB_FILES[$i]}
                    echo "TODO"
                elif [ "$confirm" = 'c'  ] || [ "$confirm" == 'C'  ]; then
                    git diff ${GITHUB_FILES[$i]} ${SYSTEM_FILES[$i]}
                    continue;
                else
                    printf "[$DATE][$color_green%-40.40s -----> %70.70s $color_white]============>[$color_yellow ignore $color_white]\n\n" ${SYSTEM_FILES[$i]} ${GITHUB_FILES[$i]}
                fi
                break
            done
        fi
    done
}

main()
{
    pre_checking;
    diff_files
    diff_dirs
}
main
