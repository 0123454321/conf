#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/0123454321/conf/main/okteto/test"
#export log_number=$(date +%Y%m%d%H%M)

echo "校正时区"
rm -f /etc/localtime 
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

echo "更新启动文件"
wget -O /init.sh   https://raw.githubusercontent.com/0123454321/conf/main/okteto/only_Cloudreve/init.sh

echo "下载CR资源文件"
if [ ! -d /mnt/data/cr ] ; then
#  mkdir -p /mnt/data/
  wget -O /mnt/data/cr.tar.gz http://175.178.175.113:2100/file/cr.tar.gz 
  tar -zxf /mnt/data/cr.tar.gz -C /mnt/data
else
  echo "资源文件已经存在，无需下载"
fi

echo "准备OD-j资源文件"
if [ ! -d /mnt/data/oneindex-j ] ; then 
  cd /mnt/data
  git clone https://github.com/jialezi/oneindex-j
else
  echo "资源文件已经存在，无需下载"
fi

echo "备份配置"
if [ ! -e /mnt/data/bak_conf.sh ] ; then
  wget -O /mnt/data/bak_conf.sh ${BASE_URL}/cron/bak_conf.sh  2> /dev/null
  chmod a+x /mnt/data/bak_conf.sh
  echo "1 */3 * * * /mnt/data/bak_conf.sh" | crontab -
else 
  echo "文件已经在在，写入定时任务"
  echo "1 */3 * * * /mnt/data/bak_conf.sh" | crontab -
fi

echo "Web Server配置文件生成"
wget -O /etc/apache2/sites-available/000-default.conf   ${BASE_URL}/apache/000-default.conf 2> /dev/null
wget -O /var/www/html/index.html   ${BASE_URL}/www/index.html 2> /dev/null
wget -O /etc/nginx/pathinfo.conf   ${BASE_URL}/nginx/pathinfo.conf 2> /dev/null
wget -O /etc/nginx/enable_php.conf   ${BASE_URL}/nginx/enable_php.conf 2> /dev/null
wget -O /etc/nginx/nginx.conf   ${BASE_URL}/nginx/nginx.conf 2> /dev/null

echo "OD-j配置文件生成"
wget -O /etc/nginx/vhost/od.conf  ${BASE_URL}/nginx/vhost/od.conf 2> /dev/null
wget -O /etc/nginx/fcgiwrap.conf https://raw.githubusercontent.com/MICHAEL-888/oneindex-j/cdn/nginx/fcgiwrap.conf 2> /dev/null
wget -O /etc/nginx/fcgiwrap-php https://raw.githubusercontent.com/MICHAEL-888/oneindex-j/cdn/nginx/fcgiwrap-php 2> /dev/null
echo "nginx配置生成"
if [ ! -d /etc/nginx/vhost ] ; then
  mkdir -p /etc/nginx/vhost
fi
wget -O /etc/nginx/vhost/reproxy.conf    ${BASE_URL}/nginx/vhost/reproxy.conf 2> /dev/null

echo "PHP配置生成"
wget -O /etc/php/7.4/fpm/pool.d/www.conf   ${BASE_URL}/php/www.conf 2> /dev/null
wget -O /root/frp/frps.ini  ${BASE_URL}/frps/frps.ini 2> /dev/null

echo "启动PHP"
mkdir /run/php
php-fpm7.4
echo "启动Web nginx,apache caddy"
nginx
service mysql restart
service apache2 restart

echo "启动CR" 
if [ ! -d /mnt/data/cr/log ] ; then
  mkdir -p /mnt/data/cr/log
fi
/mnt/data/cr/cr >> /mnt/data/cr/log/log_$(date +%Y%m%d%H%M).log 

