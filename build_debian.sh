#!/bin/bash

#Download CUDA drivers for NVidia
#wget https://developer.nvidia.com/compute/cuda/9.0/Prod/local_installers/cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64-deb /tmp
#sudo dpkg -i /tmp/cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64.deb
#sudo apt-key add /var/cuda-repo-<version>/7fa2af80.pub
#sudo apt install -y cuda
sudo apt update
sudo apt install -y libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev
cur_dir=`pwd`
git clone https://github.com/fireice-uk/xmr-stak.git /tmp/xmr
cp -R /tmp/xmr/* $cur_dir
sed -i -e 's/2/0/' xmrstak/donate-level.hpp
mkdir build
cd build
cmake -DCUDA_ENABLE=OFF -DOpenCL_ENABLE=OFF ..
make install
sudo echo "vm.nr_hugepages=128" >> /etc/sysctl.conf
sudo sysctl -w vm.nr_hugepages=128
sudo echo "* soft memlock 262144" >> /etc/security/limits.conf
sudo echo "* hard memlock 262144" >> /etc/security/limits.conf
mv ../*.txt bin/
cd bin/
/usr/bin/screen -md -S xmr ./xmr-stak
rm -rf /tmp/xmr

#Creating autostarting service for Debian
cat > /etc/rc.local <<EOF
>#!/bin/sh -e
>cd ~/xmr/build/bin
>screen -md -S xmr ./xmr-stak 
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
