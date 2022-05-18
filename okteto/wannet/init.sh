#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/0123454321/conf/main/okteto/test"
#export log_number=$(date +%Y%m%d%H%M)

echo "校正时区"
rm -f /etc/localtime 
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

echo "更新启动文件"
wget -O /init.sh   ${BASE_URL}/init.sh

echo "Server Status配置生成"
cd /root
wget -O /root/ServerStatus/server/config.json   ${BASE_URL}/ServerStatus/ServerStatus-config.json  2> /dev/null 
wget -O /root/ServerStatus/clients/client-linux.py   ${BASE_URL}/ServerStatus/ServerStatus-client-linux.py  2> /dev/null
chmod a+x /root/ServerStatus/clients/client-linux.py


echo "修改密码"
echo root:vscwjm00529 | chpasswd

echo "启动WS服务"
wstunnel -s 127.0.0.1:8989 & 
/root/ws --server  ws://0.0.0.0:81 &
/root/frp/frps -c /root/frp/frps.ini &


echo "caddy"
cd /caddy
./caddy &

#echo "写入hosts"
#echo "127.0.0.1 om.wangjm.ml" >> /etc/hosts
#echo "127.0.0.1 bd.wangjm.ml" >> /etc/hosts

/usr/sbin/sshd -D