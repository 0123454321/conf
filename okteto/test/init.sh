#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/0123454321/conf/main/okteto/test"
#export log_number=$(date +%Y%m%d%H%M)

echo "校正时区"
rm -f /etc/localtime 
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

echo "更新启动文件"
wget -O /init.sh   ${BASE_URL}/init.sh

echo "下载OM资源文件"
if [ ! -d /mnt/data/om.wangjm.ml ] ; then
  mkdir -p /mnt/data/
  wget -O /mnt/data/om.wangjm.ml.tar.gz http://175.178.175.113:2100/file/om.wangjm.ml.tar.gz
  tar -zxf /mnt/data/om.wangjm.ml.tar.gz -C /mnt/data
#  chmod -R 766 /mnt/data/om.wangjm.ml
else
  echo "资源文件已经存在，无需下载"
fi

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


echo "Server Status配置生成"
cd /root
wget -O /root/ServerStatus/server/config.json   ${BASE_URL}/ServerStatus/ServerStatus-config.json > /dev/null
wget -O /root/ServerStatus/clients/client-linux.py   ${BASE_URL}/ServerStatus/ServerStatus-client-linux.py > /dev/null
chmod a+x /root/ServerStatus/clients/client-linux.py

echo "Web Server配置文件生成"
wget -O /caddy/Caddyfile   ${BASE_URL}/caddy/Caddyfile  > /dev/null
wget -O /etc/apache2/sites-available/000-default.conf   ${BASE_URL}/apache/000-default.conf > /dev/null
wget -O /var/www/html/index.html   ${BASE_URL}/www/index.html  > /dev/null
wget -O /etc/nginx/pathinfo.conf   ${BASE_URL}/nginx/pathinfo.conf  > /dev/null
wget -O /etc/nginx/enable_php.conf   ${BASE_URL}/nginx/enable_php.conf  > /dev/null
wget -O /etc/nginx/nginx.conf   ${BASE_URL}/nginx/nginx.conf  > /dev/null

echo "OD-j配置文件生成"
wget -O /etc/nginx/vhost/od.conf  ${BASE_URL}/nginx/vhost/od.conf  > /dev/null
wget -O /etc/nginx/fcgiwrap.conf https://raw.githubusercontent.com/MICHAEL-888/oneindex-j/cdn/nginx/fcgiwrap.conf  > /dev/null
wget -O /etc/nginx/fcgiwrap-php https://raw.githubusercontent.com/MICHAEL-888/oneindex-j/cdn/nginx/fcgiwrap-php  > /dev/null

echo "om配置生成"
if [ ! -d /etc/nginx/vhost ] ; then
  mkdir -p /etc/nginx/vhost
fi
wget -O /etc/nginx/vhost/om.wangjm.ml.conf    ${BASE_URL}/nginx/vhost/om.wangjm.ml.conf > /dev/null
wget -O /etc/nginx/vhost/reproxy.conf    ${BASE_URL}/nginx/vhost/reproxy.conf > /dev/null
if [ ! -f /etc//mnt/data/log/om.wangjm.ml.log ] ; then
  mkdir -p /mnt/data/log
  touch /mnt/data/log/om.wangjm.ml.log
  touch /mnt/data/log/om.wangjm.ml.error.log;
  chmod -R 766 /mnt/data/log
fi

echo "PHP配置生成"
wget -O /etc/php/7.4/fpm/pool.d/www.conf   ${BASE_URL}/php/www.conf > /dev/null
wget -O /root/frp/frps.ini  ${BASE_URL}/frps/frps.ini > /dev/null


echo "修改密码"
echo root:vscwjm00529 | chpasswd

echo "启动PHP服务"
wstunnel -s 127.0.0.1:8989 & 
/root/ws --server  ws://0.0.0.0:81 &
/root/frp/frps -c /root/frp/frps.ini &

echo "启动PHP"
mkdir /run/php
php-fpm7.4
echo "启动Web (nginx,apache caddy)"
nginx
service mysql restart
service apache2 restart
cp -r /root/ServerStatus/web/* /var/www/html/
nohup /root/ServerStatus/clients/client-linux.py &
/root/ServerStatus/server/sergate --config=/root/ServerStatus/server/config.json --web-dir=/var/www/html &
cd /caddy
./caddy &

echo "启动R2"
/etc/init.d/r2 start

echo "启动CR" 
if [ ! -d /mnt/data/cr/log ] ; then
  mkdir -p /mnt/data/cr/log
fi
/mnt/data/cr/cr >> /mnt/data/cr/log/log_$(date +%Y%m%d%H%M).log &

#echo "写入hosts"
#echo "127.0.0.1 om.wangjm.ml" >> /etc/hosts
#echo "127.0.0.1 bd.wangjm.ml" >> /etc/hosts

/usr/sbin/sshd -D
