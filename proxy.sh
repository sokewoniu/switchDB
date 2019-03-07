#!/bin/bash
#定义转接IP
#广州
gz=203.88.218.140
gzl=192.168.1.4
#深圳
sz=117.48.218.158
szl=172.16.1.4
#中山
zs=113.106.11.23


agfwd=`iptables -L |grep -E "\s+AG-FWD\s+" | grep -o AG-FWD`
#选择目标
opt=$(whiptail \
--ok-button 确定 \
--defaultno \
--cancel-button 退出 \
--title 切换目标环境 \
--menu 请选择代理目标 \
14 50 6 \
rm 本地[删除代理] \
gz 广州[$gz] \
sz 深圳[$sz] \
zs 中山[$zs] \
yd 移动[$yd] \
3>&1 1>&2 2>&3)

#没有选择菜单项,退出
code=$?
if [ $code != 0 ]; then
  exit
fi

#没有相应的转发规则就新建
if [ "${agfwd}x" != "AG-FWDx" ]; then
  iptables -N AG-FWD
  iptables -t nat -N AG-PRE
  iptables -t nat -N AG-PST
  iptables -t nat -I PREROUTING -j AG-PRE
  iptables -t nat -I POSTROUTING -j AG-PST
  iptables -I FORWARD -j AG-FWD
fi

iptables -F AG-FWD
iptables -t nat -F AG-PRE
iptables -t nat -F AG-PST

if [ $opt != rm ]; then
  #取外网ip
  eval "ip=\$$opt"
  iptables -t nat -I AG-PST -p tcp -d $ip -j MASQUERADE
  #转发端口
  for port in 8080 5672 15674
  do
    iptables -t nat -I AG-PRE -p tcp --dport $port -j DNAT --to-destination $ip
    iptables -I AG-FWD  -p tcp -m state --state RELATED,ESTABLISHED -m tcp --sport $port -j ACCEPT
    iptables -I AG-FWD  -p tcp -m tcp --dport $port -j ACCEPT
  done
fi

