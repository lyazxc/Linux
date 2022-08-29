#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
echo
echo "######################################################################"
echo "# The configuration of FRP Client                                    #"
echo "# Author: lyz <lyazxc@outlook.com   >                                #"
echo "#You need to manually specify the public IP address and port number  #"
echo "#The corresponding port of the security group must be disabled       #"
echo "######################################################################"
echo

cd /root

yum install wget -y >> /dev/null
yum install net-tools -y >> /dev/null
yum install netcat-1.218-4.el7.x86_64 -y >>/dev/null
test -d /opt/frpc
if [ $? != 0 ] ;then
   mkdir -p /opt/frpc
fi

cd /opt/frpc

test -a frp_*_linux_amd64.tar.gz
if [ $? != 0 ];then
  echo  "The FRP installation package does not exist"
  wget  https://github.com/fatedier/frp/releases/download/v0.39.1/frp_0.39.1_linux_amd64.tar.gz
fi

tar -xf frp_*_linux_amd64.tar.gz
cd frp_*_linux_amd64

cp frpc.ini frpc.ini.bak
ip=""
read -p "Enter a public IP address: " ip
ping -c 5 -i 0.1 $ip >>/dev/null
if [ $? != 0 ] ;then
echo "The IP address is unavailable"
exit
fi
sed -i "s/^server_addr = 127.0.0.1/server_addr = $ip/g" frpc.ini

port=""
read -p "Enter the FRP Server port(default 7000~65535): " port
nc -z ${ip} ${port} &>>/dev/null
if [ $? != 0 ] ;then
  echo "Port unreachable"
  exit
fi
sed -i "s/^server_port = 7000/server_port = $port/g" frpc.ini

./frpc -c ./frpc.ini &
ps -ef | grep frpc.ini
if [ $? == 0 ] ;then
  echo "Frp has been set up"
fi

echo "Run the following command to log in to the Intranet host"
echo "eg: ssh -oPort 6000 user@ServerIP"
