#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/0123454321/conf/main/okteto/test"

echo "更新启动文件"
wget -O /init.sh   ${BASE_URL}/init.sh

echo "检查文件"
if [ ! -d /mnt/date/om.wangjm.ml ] ; then
  mkdir -p /mnt/date/om.wangjm.ml
  wget -O /mnt/date/om.wangjm.ml.tar.gz http://list.wangjm.ml/file/om.wangjm.ml.tar.gz
  tar -zxf /mnt/date/om.wangjm.ml.tar.gz -C /mnt/date
  chmod -R 766 /mnt/date/om.wangjm.ml
fi

echo "下载配置文件"
cd /root
wget -O /root/ServerStatus/server/config.json   ${BASE_URL}/ServerStatus/ServerStatus-config.json
wget -O /root/ServerStatus/clients/client-linux.py   ${BASE_URL}/ServerStatus/ServerStatus-client-linux.py
chmod a+x /root/ServerStatus/clients/client-linux.py

wget -O /caddy/Caddyfile   ${BASE_URL}/caddy/Caddyfile
wget -O /etc/apache2/sites-available/000-default.conf   ${BASE_URL}/apache/000-default.conf
wget -O /var/www/html/index.html   ${BASE_URL}/www/index.html
wget -O /etc/nginx/pathinfo.conf   ${BASE_URL}/nginx/pathinfo.conf
wget -O /etc/nginx/enable_php.conf   ${BASE_URL}/nginx/enable_php.conf
wget -O /etc/nginx/nginx.conf   ${BASE_URL}/nginx/nginx.conf

if [ ! -d /etc/nginx/vhost ] ; then
  mkdir -p /etc/nginx/vhost
fi
wget -O /etc/nginx/vhost/om.wangjm.ml.conf    ${BASE_URL}/nginx/vhost/om.wangjm.ml.conf
if [ ! -f /etc//mnt/date/log/om.wangjm.ml.log ] ; then
  mkdir -p /mnt/date/log
  touch /mnt/date/log/om.wangjm.ml.log
  touch /mnt/date/log/om.wanagjm.ml.error.log;
fi

wget -O /etc/php/7.4/fpm/pool.d/www.conf   ${BASE_URL}/php/www.conf


wget -O /root/frp/frps.ini  ${BASE_URL}/frps/frps.ini

echo "修改密码"
echo root:vscwjm00529 | chpasswd

echo "启动服务"
wstunnel -s 127.0.0.1:8989 & 
/root/ws --server  ws://0.0.0.0:81 &
/root/frp/frps -c /root/frp/frps.ini &

mkdir /run/php
php-fpm7.4
nginx
service mysql restart
service apache2 restart
cp -r /root/ServerStatus/web/* /var/www/html/
nohup /root/ServerStatus/clients/client-linux.py &
/root/ServerStatus/server/sergate --config=/root/ServerStatus/server/config.json --web-dir=/var/www/html &
cd /caddy
./caddy &

#echo "写入hosts"
#echo "127.0.0.1 om.wangjm.ml" >> /etc/hosts
#echo "127.0.0.1 bd.wangjm.ml" >> /etc/hosts

/usr/sbin/sshd -D
