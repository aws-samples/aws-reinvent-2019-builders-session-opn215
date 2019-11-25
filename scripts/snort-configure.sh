#!bin/bash
cd ~
sudo yum install git
git clone https://github.com/waymousa/aws-reinvent-2019-builders-session-opn215.git
cd aws-reinvent-2019-builders-session-opn215
sudo cp ../etc/aws-kinesis/agent.json /etc/aws-kinesis/agent.json
sudo cp ../etc/rc.d/init.d/snortd /etc/rc.d/init.d/snortd
sudo cp ../etc/snort/snort.conf /etc/snort/snort.conf
sudo cp ../etc/sysconfig/snort /etc/sysconfig/snort