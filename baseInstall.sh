#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 6+/Debian 6+/Ubuntu 14.04+
#	Description: Install the base software
#	Version: 0.0.1
#	Author: 凹凸曼
#=================================================

check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前账号没有ROOT权限，无法继续操作，请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}

check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    else
        echo -e "$red 这个垃圾脚本不支持你的系统。$none" && exit 1
    fi
	bit=`uname -m`
}
check_installcmd(){
	if [[ ${release} == "centos" ]]; then
        installcmd="yum"
    else
        installcmd="apt"
    fi
}
service_Cmd(){
	if [[ $systemd ]]; then
		systemctl $1 $2
	else
		service $2 $1
	fi
}

#更新系统
$installcmd -y --exclude=kernel* update
$installcmd -y install wget epel-release
#安装常用基础软件
$installcmd -y install vim lrzsz screen git unzip ntp crontabs net-tools telnet gcc gcc-c++ make automake autoconf libtool
#设置时区为东八区
echo yes | cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#同步时间
ntpdate cn.pool.ntp.org
#添加系统定时任务自动同步时间并重启定时任务服务
sed -i '/^.*ntpdate*/d' /etc/crontab
sed -i '$a\* * * * 1 ntpdate cn.pool.ntp.org >> /dev/null 2>&1' /etc/crontab
service_Cmd crond restart
#/etc/init.d/crond restart
#把时间写入到BIOS
hwclock -w
