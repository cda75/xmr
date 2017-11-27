#!/bin/bash

sudo apt-get update
sudo apt install screen libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev
cur_dir=`pwd`
git clone https://github.com/fireice-uk/xmr-stak.git /tmp/xmr
cp -R /tmp/xmr/* $cur_dir
mkdir build
cd build
cmake ..
make install
cd ../
mv config_xmr.txt build/bin/xmr.txt
mv config_btc.txt build/bin/btc.txt
echo "vm.nr_hugepages=128" >> /etc/sysctl.conf
sysctl -w vm.nr_hugepages=128
echo "* soft memlock 262144" >> /etc/security/limits.conf
echo "* hard memlock 262144" >> /etc/security/limits.conf
cd build/bin/
/usr/bin/screen -md -S xmr ./xmr-stak xmr.txt
rm -rf /tmp/xmr

#Creating autostarting service for Debian
cat > /etc/rc.local <<EOF
>#!/bin/sh -e
>cd ~/xmr/build/bin
>screen -md -S xmr ./xmr-stak-cpu xmr.txt
>exit 0
>EOF
#Enable rc.local service
cat > /etc/systemd/system/rc-local.service <<EOF
>[Unit]
>Description=/etc/rc.local Compatibility
>ConditionPathExists=/etc/rc.local
>
>[Service]
>Type=forking
>ExecStart=/etc/rc.local start
>TimeoutSec=0
>StandardOutput=tty
>RemainAfterExit=yes
>SysVStartPriority=99
>
>[Install]
>WantedBy=multi-user.target
>EOF
systemctl enable rc-local
systemctl start rc-local.service



