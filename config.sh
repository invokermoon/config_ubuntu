#!/bin/bash
curdir=`pwd`
user_name="sherlock"
user_home="/home/sherlock"
backup_dir="/home/sherlock/backup_dir"

config_vim()
{
	if [ -f $user_home/.vimrc ];then
		echo -e "\033[32m[vimrc is exist,we back up it to $backup_dir/vimrc_bak]\033[0m"
		cp $user_home/.vimrc $backup_dir/vimrc_bak
	fi
	cp $curdir/vimrc $user_home/.vimrc
	vim_home="$user_home/.vim"
	mkdir -p  $vim_home
	cp $curdir/vim/* $vim_home/ -rf
	#Setup the Vundle
	git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	echo -e "\033[32m[$FUNCNAME have been configured]\033[0m"
	chown -R $user_name: $user_home/.vimrc
	chown -R $user_name: $vim_home
}
config_ssh()
{
	if [ -d $user_home/.ssh ];then
		echo -e "\033[32m	[ssh is exist,we back up it to $backup_dir/ssh_bak"
		cp $user_home/.ssh $backup_dir/ssh_bak -rf
	fi
	ssh_home="$user_home/.ssh"
	mkdir -p $ssh_home
	cp $curdir/ssh/* $ssh_home/ -rf
	echo -e "\033[32m	You should enable ssh by\033[0m \033[31mssh-add\033[0m"
	echo -e "\033[32m[$FUNCNAME have been configured]\033[0m"
	chown -R $user_name: $ssh_home
}
config_git()
{
	if [ -f $user_home/.gitconfig ];then
		echo -e "\033[32m[gitconfig is exist,we back up it to $backup_dir/gitconfig_bak]\033[0m"
		cp $user_home/.gitconfig $backup_dir/gitconfig_bak
	fi
	cp $curdir/gitconfig $user_home/.gitconfig
	cp $curdir/git-repo.git $user_home/		-rf
	echo -e "\033[32m[$FUNCNAME have been configured]\033[0m"
	chown -R $user_name:  $user_home/.gitconfig
}

config_bin()
{
	bin_home="$user_home/bin"
	if [ ! -d $bin_home ]
	then
		mkdir -p $bin_home
	fi
	cp $curdir/bin/*  $bin_home/ -rf
	echo -e "\033[32m[$FUNCNAME have been configured]\033[0m"
	chown -R $user_name:  $bin_home
}

create_share_dir()
{
	is_user_root;
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
	fi
	echo -e "\033[32m[$FUNCNAME have been configured]\033[0m"
}

config_samba()
{
	if [ -f /etc/samba/smb.conf ]; then
		create_share_dir;
	else
		echo -e "\033[31m[Please apt-get install samba first]\033[0m"
	fi
	echo -e "\033[32m[$FUNCNAME have been configured]\033[0m"
}

config_bashrc()
{
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

mkdir -p ~/.trash
alias rm=trash
alias rl='ls ~/.trash'
alias ur=undelfile
undelfile()
{
	mv -i ~/.trash/\$@ ./
}
trash()
{
	read -p "clear sure?[y/n/trash]" confirm
	if [ "\$confirm" = 'y'  ] || [ "\$confirm" == 'Y'  ]; then
		/bin/rm \$@
	elif [ "\$confirm" = 'n'  ] || [ "\$confirm" == 'N'  ]; then
		echo "not remove"
	else
		mv \$@ ~/.trash
	fi
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
	echo -e "\033[32m[$FUNCNAME have been configured]\033[0m"
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
	is_user_root;
	echo -e "\033[32m[Installing base software...]\033[0m"
	apt-get update
	apt-get install git samba ssh vim-common vim-gtk  exuberant-ctags cscope
}

check_tools_version()
{
	DOXYGEN_MIN_VERSION="1.8.0"
	# Check the version of Doxygen
	python $curdir/build/check_doxygen_version.py $(DOXYGEN_MIN_VERSION)
}

setup_post_tools()
{
	is_user_root;

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
	if [ `grep -c "Ubuntu 12.04" /etc/issue` -eq 1 ];then apt-get build-dep qemu-kvm;else apt-get build-dep qemu;fi
	apt-get install libexpat1-dev libcairo-dev
	apt-get install libsdl-image1.2-dev

	#check_tools_version;
	echo -e "\033[32m[$FUNCNAME have been configured]\033[0m"
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
	backup_dir="/home/$user_name/backup_dir"
	echo -e "\033[32m[Create the backup dir $backup_dir]\033[0m"
	mkdir -p $backup_dir
}

config_terminal_tab_color()
{
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
	echo -e "\033[32m[$FUNCNAME have been configured]\033[0m"
}

main()
{
	is_user_root
	is_user_valid	$1
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
