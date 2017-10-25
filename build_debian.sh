#!/bin/bash
apt-get update
apt-get install -y screen libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev
cur_dir=`pwd`
git clone https://github.com/fireice-uk/xmr-stak-cpu.git /tmp/xmr
cp -R /tmp/xmr/* $cur_dir
cmake -DCMAKE_LINK_STATIC=ON .
make install
cp config_xmr.txt bin/
cp config_btc.txt bin/
echo "vm.nr_hugepages=128" >> /etc/sysctl.conf
sysctl -w vm.nr_hugepages=128
echo "* soft memlock 262144" >> /etc/security/limits.conf
echo "* hard memlock 262144" >> /etc/security/limits.conf
cd bin/
/usr/bin/screen -md -S xmr ./xmr-stak-cpu config_xmr.txt
