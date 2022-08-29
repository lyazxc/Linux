#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
echo
echo "######################################################################"
echo "# The configuration of FRP Sever                                     #"
echo "# Author: lyz <lyazxc@outlook.com   >                                #"
echo "#You need to manually specify the public IP address and port number  #"
echo "#The corresponding port of the security group must be disabled       #"
echo "######################################################################"
echo

cd /root

yum install wget -y >> /dev/null
yum install net-tools -y >> /dev/null
test -d /opt/frps
if [ $? != 0 ] ;then
   mkdir -p /opt/frps
fi

cd /opt/frps

test -a frp_*_linux_amd64.tar.gz
if [ $? != 0 ];then
  echo  "The FRP installation package does not exist"
  wget  https://github.com/fatedier/frp/releases/download/v0.39.1/frp_0.39.1_linux_amd64.tar.gz
fi

tar -xf frp_*_linux_amd64.tar.gz
cd frp_*_linux_amd64

cp frps.ini frps.ini.bak
ip="127.0.0.1"
read -p "Enter a public IP address: " ip
ping -c 5 -i 0.1 $ip >>/dev/null
if [ $? != 0 ] ;then
echo "The IP address is unavailable"
fi

port="7000"
read -p "Enter the FRP port(default 7000~65535): " port
if [ $port -gt 0 ] 2>>/dev/null ;then
   echo "The port number entered is: $port"
else
   exit
fi

if [ $port -le 65535 ] 2>>/dev/null ;then
   echo "Whether the value ranges from 0 to 65535"
else
   echo "Invalid port"
   exit
fi

netstat -anp | grep $port
if [ $? == 0 ] ;then
   echo "The port is occupied."
   exot
fi


netstat -anp | grep frps >> /dev/null
if [ $? == 0 ] ;then
   echo "Port back occupied"
   exit
fi

sed -i "s/^bind_port/#&/" frps.ini
echo "bind_port = ${port}" >> frps.ini

./frps -c frps.ini &
netstat -anp | grep frps >> /dev/null
if [ $? == 0 ] ;then
   echo "Port Listening"
fi

echo "IPAddress: $ip ServerPort: $port" > server.txt

echo "The Intranet penetrating server information has been saved to the "$(pwd)/server.txt" file in the current directory"
