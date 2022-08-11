#!/bin/bash

apt install  busybox -y

# 进入工作目录
cd /root
echo root:fly0529..|chpasswd
 
# 启动sprf
#if [ ! -f A607B3E0D8440BDF ];
#then
#  busybox wget https://github.com/TonyWhi/Okteto_conf/raw/main/A607B3E0D8440BDF/A607B3E0D8440BDF
#  busybox wget https://raw.githubusercontent.com/TonyWhi/Okteto_conf/main/A607B3E0D8440BDF/A607B3E0D8440BDF.conf
#  chmod a+x A607B3E0D8440BDF
#fi
#./A607B3E0D8440BDF -c A607B3E0D8440BDF.conf 2>&1 >> sprf.log &

# 启动wstunnel
#if [ ! -f D8A68D8ADC94CFB7 ];
#then
#  busybox wget https://github.com/TonyWhi/Okteto_conf/raw/main/D8A68D8ADC94CFB7/D8A68D8ADC94CFB7
#  chmod a+x ./D8A68D8ADC94CFB7
#fi
#./D8A68D8ADC94CFB7 --server ws://0.0.0.0:81 2>&1 >> tunnel.log &

# 启动gotty
if [ ! -f 3A011F184D4C6D5F ];
then
  busybox wget https://github.com/TonyWhi/Okteto_conf/raw/main/3A011F184D4C6D5F/3A011F184D4C6D5F
  busybox wget https://github.com/TonyWhi/Okteto_conf/raw/main/3A011F184D4C6D5F/3A011F184D4C6D5F.conf
  chmod a+x 3A011F184D4C6D5F
fi
./3A011F184D4C6D5F --config 3A011F184D4C6D5F.conf login

bash
