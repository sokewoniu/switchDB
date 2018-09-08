#!/bin/bash
echo 修改配置文件$2
if [ $# != 2 ];then
  echo '参数错误'
  exit 1
fi
#第一个参数为数据库连接参数,第二个参数为文件路径
if [ ! -f "$2" ];then
  echo $2'不存在'
  exit 1
fi


#修改python脚本数据连接参数
sed  -nr "/zs_imtos\/ok@/=;s%.*(zs_imtos/ok)@([^'\"]*).*%\2->$1%p" $2 |sed "s/.*/修改第&行内容/;N;s/\n/ /"
sed  -i -r "s%(zs_imtos/ok)@[^'\"]*%\1@$1%" $2

echo 修改完成

