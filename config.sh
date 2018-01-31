#!/bin/bash
curdir=`pwd`
user_name="sherlock"
user_home="/home/sherlock"
let first_flag=2

backup_dir="$curdir/backup_dir"
bashrc_file=$curdir/base_files/bashrc
bashrc_diff=$curdir/base_files/bashrc.diff
vimrc_file=$curdir/base_files/vimrc
vim_dir=$curdir/base_files/vim
gitconfig_file=$curdir/base_files/gitconfig
bin_dir=$curdir/base_files/bin
ssh_dir=$curdir/base_files/ssh
gtkcss_file=$curdir/base_files/gtk.css

color_none="\033[m"
color_red="\033[0;32;31m"
color_light_red="\033[1;31m"
color_green="\033[0;32;32m"
color_blue="\033[0;32;34m"
color_brown="\033[0;33m"
color_yellow="\033[1;33m"
color_white="\033[1;37m"

print_result()
{
    if [ "$2" == "failed" ]; then
        printf "[$color_red DIFF $color_white][%-25.25s]============================================================[$color_red failed $color_white]\n\n" $1
    elif [ "$2" == "ok" ]; then
        printf "[$color_red DIFF $color_white][%-25.25s]============================================================[$color_green ok $color_white]\n\n" $1
    elif [ "$2" == "ignore" ]; then
        printf "[$color_red DIFF $color_white][%-25.25s]============================================================[$color_yellow ignore $color_white]\n\n" $1
    elif [ "$2" == "same" ]; then
        printf "[$color_light_red SAME $color_white][%-25.25s]============================================================[$color_green ok $color_white]\n\n" $1
    else
        printf "[$color_red DIFF $color_white][%-25.25s]============================================================[$color_red unknow $color_white]\n\n" $1
        exit
    fi
}

skip_this_step()
{
    if [ $first_flag == 2 ]; then
        echo -e "[$color_light_red Auto setting all envs$color_white? yes/no [$color_red no $color_white]]\c"
        read confirm 
        if [ "$confirm" = 'y'  ] || [ "$confirm" == 'Y'  ]; then
            first_flag=1
        else
            first_flag=0
        fi
    fi

    if [ $first_flag == 0 ]; then
        #check if diff?
        if [ ! -z $2 ] && [ ! -z $3 ]; then
            diff  $2 $3 >/dev/null 2>&1
            if [ $? == 0 ]; then
                print_result $1 "same"
                #skip when same
                return 1
            fi
        fi

        while [ 1 ]; do
            echo -e "[Execute $color_green$1$color_white? yes/no/check [$color_red no $color_white]]\c"
            read confirm 
            if [ "$confirm" = 'y'  ] || [ "$confirm" == 'Y'  ]; then
                return 0;
            elif [ "$confirm" = 'c'  ] || [ "$confirm" == 'C'  ]; then
                if [ ! -z $2 ] && [ ! -z $3 ]; then
                    git diff  $2 $3
                else
                echo -e "No diff files\n"
                fi
                continue
            else
                print_result $1 "ignore"
                return 1;
            fi
            return 0;
        done
    fi
}

config_vim()
{
    skip_this_step $FUNCNAME $vimrc_file $user_home/.vimrc 
    if [ $? == 1 ] ; then
       return  
    fi
    if [ -f $user_home/.vimrc ]; then
		echo -e "\033[32m[vimrc is exist,we back up it to $backup_dir/vimrc_bak]\033[0m"
		cp $user_home/.vimrc $backup_dir/vimrc_bak
	fi
	install $vimrc_file $user_home/.vimrc
	vim_home="$user_home/.vim"
	mkdir -p  $vim_home
	cp $vimr_dir/* $vim_home/ -rf
	#Setup the Vundle
	#git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	chown -R $user_name: $user_home/.vimrc
	chown -R $user_name: $vim_home
    print_result $FUNCNAME "ok"
}
config_ssh()
{
    skip_this_step $FUNCNAME 
    if [ $? == 1 ] ; then
       return  
    fi

	if [ -d $user_home/.ssh ]; then
		echo -e "\033[32m	[ssh is exist,we back up it to $backup_dir/ssh_bak"
		cp $user_home/.ssh $backup_dir/ssh_bak -rf
	fi
	ssh_home="$user_home/.ssh"
	mkdir -p $ssh_home
	cp $ssh_dir/* $ssh_home/ -rf
	echo -e "\033[32m	You should enable ssh by\033[0m \033[31mssh-add\033[0m"
	chown -R $user_name: $ssh_home
    print_result $FUNCNAME "ok"

}
config_git()
{
    skip_this_step $FUNCNAME $gitconfig_file $user_home/.gitconfig
    if [ $? == 1 ] ; then
       return  
    fi

	if [ -f $user_home/.gitconfig ]; then
		echo -e "\033[32m[gitconfig is exist,we back up it to $backup_dir/gitconfig_bak]\033[0m"
		cp $user_home/.gitconfig $backup_dir/gitconfig_bak
	fi
	cp $gitconfig_file $user_home/.gitconfig
	cp $curdir/git-repo.git $user_home/		-rf
	chown -R $user_name:  $user_home/.gitconfig
    print_result $FUNCNAME "ok"
}

config_bin()
{
    skip_this_step $FUNCNAME $bin_dir/*  $bin_home/
    if [ $? == 1 ] ; then
       return  
    fi

	bin_home="$user_home/bin"
	if [ ! -d $bin_home ]
	then
		mkdir -p $bin_home
	fi
	cp $bin_dir/*  $bin_home/ -rf
	chown -R $user_name:  $bin_home
    print_result $FUNCNAME "ok"
}

create_samba_share_dir()
{
	is_user_root;
    if [ $? == 1 ] ; then
       return  
    fi

	echo -e "\033[32m[Create the samba share dir /home/share]\033[0m"
	mkdir -p /home/share
	chmod 0777 /home/share
	#smb_user=`cat /etc/passwd | awk -F: '$3>=500' | cut -f 1 -d:|sed -n "2p"`
	if [ -z "$user_name" ]
	then
		echo -e "\033[31m[Please input the right smb_user]\033[0m"
		return
	fi
	smb_user=$user_name
cat >>/etc/samba/smb.conf <<EOF
#Beginning of sherlock!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[share]
	comment = Doc
	path = /home/share
	browseable = yes
	writeable =yes
	create mask = 0765
	directory mask = 0765
	public = yes
	#guest ok= yes
	valid users = $smb_user
#Endding of sherlock!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOF
	printf "0\n0\n" | smbpasswd -s -a $smb_user
	if [ $? -eq 0 ]; then
		echo -e "\033[32m	[Create a smb accout named $smb_user,passwd 0 OK]\033[0m"
	else
		echo -e "\033[31m	[Create a smb accout named $smb_user,passwd 0 error]\033[0m"
        print_result $FUNCNAME "failed"
    fi
    print_result $FUNCNAME "ok"
}

config_samba()
{
    skip_this_step $FUNCNAME
    if [ $? == 1 ] ; then
       return  
    fi

	if [ -f /etc/samba/smb.conf ]; then
		create_samba_share_dir;
	else
		echo -e "\033[31m[Please apt-get install samba first]\033[0m"
        print_result $FUNCNAME "failed"
    fi
    print_result $FUNCNAME "ok"
}

config_bashrc()
{
   skip_this_step $FUNCNAME $user_home/.bashrc $bashrc_file
    if [ $? == 1 ] ; then
        return 
    fi
    if [ -f $user_home/.bashrc ]; then
        echo -e "$color_red[$user_home/bashrc is exist,back up it to $backup_dir/bashrc]$color_white"
        cp $user_home/.bashrc $backup_dir/bashrc
    else
        echo -e "$color_red $user_home/bashrc is not exist,error$color_white"
        print_result $FUNCNAME "failed"
        return
    fi
    DIFF=`diff $user_home/.bashrc $bashrc_file`
    if [ ! -z "$DIFF" ]; then
        while [ 1 ]; do
            echo -e "Copy: $color_BROWN $bashrc_file ---> $color_BROWN $user_home/.bashrc $color_WHITE\n[y/n/check$color_GREEN[no]$color_WHITE]"
            read confirm
            if [ "$confirm" == 'y'  ] || [ "$confirm" == 'Y'  ]; then
                install $bashrc_file $user_home/.bashrc
                chown -R $user_name: $user_home/.bashrc
                print_result $FUNCNAME "ok"
            elif [ "$confirm" = 'c'  ] || [ "$confirm" == 'C'  ]; then
                diff `$user_home/.bashrc $bashrc_file >$bashrc_diff`
                continue;
            else
                print_result $FUNCNAME "ignore"
            fi
            echo "[$DATE]================================================================="
            break
        done
    fi
}

config_bashrc2()
{
    skip_this_step $FUNCNAME
    if [ $? == 1 ] ; then
        return 
    fi

	ret=`grep -rn "Beginning of sherlock" $user_home/.bashrc|wc -l`
	if [ $ret -ne 0 ]; then
		echo -e "\033[31m[bashrc had been configured,ignore this time]\033[0m"
		return
	fi
cat >>$user_home/.bashrc  <<EOF
#Beginning of sherlock!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#For base
export PATH=\$PATH:~/bin

#For intel
#add by for android building
#export PATH=/usr/lib/jvm/java-6-sun/bin:\$PATH
export JAVA_HOME=~/envtools/Android_studio/jdk1.7.0_71
export JDK_HOME=~/envtools/Android_studio/jdk1.7.0_71
#export PATH=\$PATH:\$JDK_HOME/bin
#export PATH=\$PATH:~/envtool/poky/bitbake/bin
#export PATH=/home1/fanghu1x/pshsdk/toolchain/linux-x86_64/i686-elf-gcc/bin:\$PATH
#export PATH=~/bin/i686-elf-gcc/bin:\$PATH

#For proxy
#export GIT_PROXY_COMMAND=/usr/local/bin/socks-gateway
#export TERM=xterm
#export http_proxy='http://proxy-shz.intel.com:912/'
#export https_proxy='http://proxy-shz.intel.com:912/'
#export ftp_proxy='http://proxy-shz.intel.com:912/'
#export http_proxy='http://proxy.cd.intel.com:911/'
#export https_proxy='http://proxy.cd.intel.com:911/'
#export ftp_proxy='http://proxy.cd.intel.com:911/'
#*************************************************

#Set the title name
function title-set() {
	if [[ -z "\$ORIG" ]]; then
		ORIG=\$PS1
	fi
	TITLE="\[\e]2;\$*\a\]"
	PS1=\${ORIG}\${TITLE}
}

color_NONE="\033[m"
color_RED="\033[0;32;31m"
color_LIGHT_RED="\033[1;31m"
color_GREEN="\033[0;32;32m"
color_BLUE="\033[0;32;34m"
color_BROWN="\033[0;33m"
color_YELLOW="\033[1;33m"
color_WHITE="\033[1;37m"


mkdir -p ~/.trash
alias rm=trash
alias rl='ls ~/.trash'
alias ur=undelfile
undelfile()
{
    echo -e \$color_BROWN "Refind the deleted files"\$color_WHITE
	mv -i ~/.trash/\$@ ./
}
trash()
{
    local del_files=\$(echo \$@ | sed -n 's/-rf//g;p')
    echo -e \$color_GREEN"remove the dir:"
    readlink -f \$del_files
    echo -e \$color_RED
	read -p "clear sure?[y/n/trash]" confirm
	if [ "\$confirm" = 'y'  ] || [ "\$confirm" == 'Y'  ]; then
		/bin/rm \$del_files -rf
	elif [ "\$confirm" = 'T'  ] || [ "\$confirm" == 't'  ]; then
		mv \$del_files ~/.trash/
		echo -e \$color_BROWN"Mv to ~/.trash"\$color_WHITE
    else
		echo "Delete failed"
	fi
    echo -e \$color_WHITE
}

cleartrash()
{
	read -p "clear sure?[y/n]" confirm
	[ \$confirm == 'y'  ] || [ \$confirm == 'Y'  ]  && /bin/rm -rf ~/.trash/*
}

#*************************************************

funcs_complete()
{
    local cur
    cur=\${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=(`global -c \$cur`)
}
complete -F funcs_complete global

#Must in the end
source ~/bin/bashmarks.sh
#Ending of sherlock!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOF
	source  $user_home/.bashrc
    print_result $FUNCNAME "ok"
}

is_user_root()
{
	if [ `whoami` != root ]; then
		echo -e "\033[31m[Please run as sudoer/root]\033[0m";
		exit 1;
	fi
}

setup_base_tools()
{
    skip_this_step $FUNCNAME
    if [ $? == 1 ] ; then
       return 
    fi

    is_user_root;
    echo -e "\033[32m[Installing base software...]\033[0m"
    apt-get update
    apt-get install git samba ssh vim-common vim-gtk  exuberant-ctags cscope;
    print_result $FUNCNAME "ok"
}

check_tools_version()
{
	DOXYGEN_MIN_VERSION="1.8.0"
	# Check the version of Doxygen
	python $curdir/envtools/check_doxygen_version.py $(DOXYGEN_MIN_VERSION)
}

setup_post_tools()
{
	is_user_root;
    skip_this_step $FUNCNAME
    if [ $? == 1 ] ; then
        return 
    fi

	echo -e "\033[32m[Installing base build dependencies...]\033[0m"
	apt-get install python gawk git-core diffstat unzip zip texinfo gcc-multilib \
		build-essential chrpath libtool libc6:i386 doxygen graphviz tmux     \
		libc6-dev-i386 uncrustify mscgen vim-common pigz libdbus-1-dev \
		libglib2.0-dev
	echo -e "\033[32m[Installing kconfig front-ends dependencies...]\033[0m"
	apt-get install autoconf pkg-config gperf flex bison libncurses5-dev
	echo -e "\033[32m[Installing protobuf compiler dependencies...]\033[0m"
	apt-get install protobuf-compiler python-protobuf
	echo -e "\033[32m[Installing qemu emulator dependencies...]\033[0m"
	if [ `grep -c "Ubuntu 12.04" /etc/issue` -eq 1 ]; then apt-get build-dep qemu-kvm; else apt-get build-dep qemu; fi
	apt-get install libexpat1-dev libcairo-dev
	apt-get install libsdl-image1.2-dev

	#check_tools_version;
    print_result $FUNCNAME "ok"

}

create_backdir()
{
    backup_dir="$curdir/backdir/$user_name"
    echo -e "\033[32m[Create the backup dir $backup_dir]\033[0m"
    mkdir -p $backup_dir
    print_result $FUNCNAME "ok"
}

is_user_valid()
{
	#user=`cat /etc/passwd | awk -F: '$3>=500' | cut -f 1 -d:|sed -n "2p"`
	user_name=$1
	while [ -z "$user_name" ] || [ ! -d /home/$user_name ]
	do
		echo -e "\033[31m[Please input the right user name:]\033[0m \c"
		read user_name
	done
	user_home="/home/$user_name"
}

config_terminal_tab_color()
{
    skip_this_step $FUNCNAME  $gtkcss_file $user_home/.config/gtk-3.0/gtk.css
    if [ $? == 1 ] ; then
        return
    fi

	ret=`cat /etc/issue|awk '{print substr($2,0,5)}'`
	if [ `echo "$ret > 12.04"|bc` -eq 0 ]
	then
		echo -e "\033[31m[Less than 12.04:]\033[0m"
		echo -e "\033[31m	You should refer to:http://ubuntuforums.org/showthread.php?t=2038854\033[0m"
		echo -e "\033[31m	Modify:/usr/share/themes/Ambiance/gtk-3.0/gtk-widgets.css\033[0m"
		return
	fi
	if [ -d ~/.config/gtk-3.0 ]
	then
cat >>$user_home/.config/gtk-3.0/gtk.css <<EOF
TerminalWindow .notebook tab:active {
    background-color: #b0c0f0;
}
EOF
	fi
    print_result $FUNCNAME "ok"
}

main()
{
	is_user_root
	is_user_valid	$1
    create_backdir
    setup_base_tools
	config_vim;
	config_ssh;
	config_git;
	config_bin;
	config_samba;
	config_bashrc;
	#setup_post_tools;
	config_terminal_tab_color;
}
main $@;
