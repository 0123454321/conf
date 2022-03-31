#!/bin/bash

echo "更新启动文件"
wget -O /init.sh   https://raw.githubusercontent.com/0123454321/conf/main/okteto/test/init.sh

echo "安装服务"
if [ ! -f /root/rc.zip  ] ; then
  wget -O /root/rc.zip https://github.com/rclone/rclone/releases/download/v1.58.0/rclone-v1.58.0-linux-amd64.zip
  unzip /root/rc.zip -d /root/
  mv /root/rclone-v1.58.0-linux-amd64 /root/rc
  mv /root/rc/rclone /root/rc/rc
fi

echo "下载配置文件"
cd /root
wget -O /root/ServerStatus/server/config.json   https://raw.githubusercontent.com/0123454321/conf/main/okteto/test/ServerStatus/ServerStatus-config.json
wget -O /root/ServerStatus/clients/client-linux.py   https://raw.githubusercontent.com/0123454321/conf/main/okteto/test/ServerStatus/ServerStatus-client-linux.py
chmod a+x /root/ServerStatus/clients/client-linux.py

wget -O /caddy/Caddyfile   https://raw.githubusercontent.com/0123454321/conf/main/okteto/test/caddy/Caddyfile
wget -O /etc/apache2/sites-available/000-default.conf   https://raw.githubusercontent.com/0123454321/conf/main/okteto/test/apache/000-default.conf
wget -O /var/www/html/index.html   https://raw.githubusercontent.com/0123454321/conf/main/okteto/test/www/index.html
wget -O /etc/nginx/enable_php.conf   https://raw.githubusercontent.com/0123454321/conf/main/okteto/test/nginx/enable_php.conf
wget -O /etc/nginx/nginx.conf   https://raw.githubusercontent.com/0123454321/conf/main/okteto/test/nginx/nginx.conf
wget -O /etc/nginx/vhost/om.wangjm.ml.conf    https://raw.githubusercontent.com/0123454321/conf/main/okteto/test/nginx/vhost/om.wangjm.ml.conf
wget -O /etc/php/7.4/fpm/pool.d/www.conf   https://raw.githubusercontent.com/0123454321/conf/main/okteto/test/php/www.conf

wget -O /root/frp/frps.ini  https://raw.githubusercontent.com/0123454321/conf/main/okteto/test/frps/frps.ini

echo "修改密码"
echo root:vscwjm00529 | chpasswd

echo "启动服务"
wstunnel -s 127.0.0.1:8989 & 
/root/ws --server  ws://0.0.0.0:81 &
/root/frp/frps -c /root/frp/frps.ini &
service mysql restart
service apache2 restart
cp -r /root/ServerStatus/web/* /var/www/html/
nohup /root/ServerStatus/clients/client-linux.py &
/root/ServerStatus/server/sergate --config=/root/ServerStatus/server/config.json --web-dir=/var/www/html &
cd /caddy
./caddy &

echo "写入hosts"
echo "127.0.0.1 om.wangjm.ml" >> /etc/hosts
echo "127.0.0.1 bd.wangjm.ml" >> /etc/hosts

/usr/sbin/sshd -D
