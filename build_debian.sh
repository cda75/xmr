#!/bin/bash
apt-get update
apt-get install -y screen libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev
cur_dir=`pwd`
git clone https://github.com/fireice-uk/xmr-stak-cpu.git /tmp/xmr
cp -R /tmp/xmr/* $cur_dir
cmake -DCMAKE_LINK_STATIC=ON .
make install
mv config_xmr.txt bin/xmr.txt
mv config_btc.txt bin/btc.txt
echo "vm.nr_hugepages=128" >> /etc/sysctl.conf
sysctl -w vm.nr_hugepages=128
echo "* soft memlock 262144" >> /etc/security/limits.conf
echo "* hard memlock 262144" >> /etc/security/limits.conf
cd bin/
/usr/bin/screen -md -S xmr ./xmr-stak-cpu xmr.txt
rm -rf /tmp/xmr
cat > /etc/rc.local <<EOF
>#!/bin/sh -e
>cd ~/xmr2/bin
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



