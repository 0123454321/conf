#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/0123454321/conf/main/okteto/test"

export PATH=~/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/sbin:/bin:/mnt/data/R2
R2_conf_dir="/mnt/data/R2/Conf"
download_path="/root/downloads"
R2_conf="${R2_conf_dir}/R2.conf"
aria2_log="${R2_conf_dir}/R2.log"
R2c="/mnt/data/R2/R2"

echo "更新启动文件"
wget -O /init.sh   ${BASE_URL}/init.sh

echo "下载OM资源文件"
if [ ! -d /mnt/data/om.wangjm.ml ] ; then
#  mkdir -p /mnt/data/om.wangjm.ml
  wget -O /mnt/data/om.wangjm.ml.tar.gz http://list.wangjm.ml/file/om.wangjm.ml.tar.gz
  tar -zxf /mnt/data/om.wangjm.ml.tar.gz -C /mnt/data
#  chmod -R 766 /mnt/data/om.wangjm.ml
fi

echo "下载R2"
if [ ! -d /mnt/data/R2 ] ; then
  wget -O /mnt/data/R2/R2.tar.gz ${BASE_URL}/R2/R2.tar.gz
  tar -zxf /mnt/data/R2/R2.tar.gz -C /mnt/data/R2
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
wget -O /etc/nginx/vhost/reproxy.conf    ${BASE_URL}/nginx/vhost/reproxy.conf
if [ ! -f /etc//mnt/data/log/om.wangjm.ml.log ] ; then
  mkdir -p /mnt/data/log
  touch /mnt/data/log/om.wangjm.ml.log
  touch /mnt/data/log/om.wangjm.ml.error.log;
  chmod -R 766 /mnt/date/log
fi

wget -O /etc/php/7.4/fpm/pool.d/www.conf   ${BASE_URL}/php/www.conf
wget -O /root/frp/frps.ini  ${BASE_URL}/frps/frps.ini

weget -O /mnt/data/R2/R2_Conf.tar.gz ${BASE_URL}/R2/R2_Conf.tar.gz
tar -zxf R2_Conf.tar.gz -C /mnt/data/R2
    cd ${R2_conf_dir}
    sed -i "s@^\(dir=\).*@\1${download_path}@" ${R2_conf}
    sed -i "s@/root/.aria2/@${aria2_conf_dir}/@" ${R2_conf_dir}/*.conf
    sed -i "s@^\(rpc-secret=\).*@\1$(date +%s%N | md5sum | head -c 20)@" ${R2_conf}
    sed -i "s@^#\(retry-on-.*=\).*@\1true@" ${R2_conf}
    sed -i "s@^\(max-connection-per-server=\).*@\132@" ${R2_conf}
    touch R2.session
    chmod +x *.sh


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
