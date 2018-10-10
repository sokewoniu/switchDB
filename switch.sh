#!/bin/bash
#定义数据库连接IP
#广州
gz=203.88.218.140
gzl=192.168.1.4
#深圳
sz=117.48.218.158
szl=192.168.1.4
#中山
zs=113.106.11.23
zsl=192.168.100.102
#移动
yd=14.29.38.102
ydl=172.31.250.1

#定义程序根目录
root=/app

#选择数据库
opt=$(whiptail \
--ok-button 确定 \
--defaultno \
--cancel-button 退出 \
--title 切换数据库 \
--menu 请选择要切换的数据库 \
14 50 6 \
gz 广州$gz \
sz 深圳$sz \
zs 中山$zs \
yd 移动$yd \
3>&1 1>&2 2>&3)

#没有选择菜单项,退出
code=$?
if [ $code != 0 ]; then
  exit
fi


#取内网ip
eval "ipl=\$${opt}l"
#取外网ip
eval "ip=\$$opt"
if (whiptail \
--title 选择ip \
--yesno \
--yes-button 是 \
--no-button 否 \
--defaultno "内网ip:$ipl,外网ip:$ip\n默认使用外网ip,是否使用内网?" \
8 50) then
  ip=$ipl
fi

cd `dirname $0`
clear

#修改python脚本数据连接参数
find $root -name config.ini -exec ./switchPython.sh $ip:1521/ghdb$opt {} \;

#修改tomcat数据连接参数
find $root -name datasource.properties -exec ./switchTomcat.sh $ip:1521:ghdb$opt {} \;

find $root -name context.xml -exec ./switchTomcat.sh $ip:1521:ghdb$opt {} \;