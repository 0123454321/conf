#!/bin/bash

echo "更新启动文件"
wget -O /1.sh https://raw.githubusercontent.com/0123454321/conf/main/Railway/ws/1.sh

echo. "修改密码"
echo root:wangjm0529 | chpasswd

echo "下载配置文件"
wget -O /root/frp/frps.ini  https://raw.githubusercontent.com/0123454321/conf/main/Railway/ws/frps/frps.ini
#wget -O /root/client-linux.py  https://raw.githubusercontent.com/0123454321/conf/main/Railway/ws/ServerStatus/ServerStatus-client-linux.py
#chmod a+x /root/client-linux.py

wget -O /V3/config.json  https://raw.githubusercontent.com/0123454321/conf/main/Railway/ws/v3/v3_config.json
wget -O /V3/vmess.json  https://raw.githubusercontent.com/0123454321/conf/main/Railway/ws/v3/v3_vmess.json

echo. "启动服务"
chmod a+x /root/wstunnel-x64-linux
# nohup /root/wstunnel-x64-linux -L 0.0.0.0:35601:127.0.0.1:35601 wss://test-81-web-gbjkld.cloud.okteto.net &
/root/wstunnel-x64-linux --server  ws://0.0.0.0:80 &
/root/frp/frps -c /root/frp/frps.ini &
nohup /root/client-linux.py &'
cd /V3
./v3 &
/usr/sbin/sshd -D
