#!/bin/bash
apt-get update
apt-get install -y screen libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev
git clone https://github.com/fireice-uk/xmr-stak-cpu.git /tmp
cd /tmp/xmr-stak-cpu
cmake -DCMAKE_LINK_STATIC=ON .
make install
cp config_xmr.txt bin/
cp config_btc.txt bin/
echo "vm.nr_hugepages=128" >> /etc/sysctl.conf
sysctl -w vm.nr_hugepages=128
echo "* soft memlock 262144" >> /etc/security/limits.conf
echo "* hard memlock 262144" >> /etc/security/limits.conf
cd bin/
/usr/bin/screen -md -S xmr ./xmr-stak-cpu config_btc.txt
