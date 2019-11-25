#!/bin/bash
echo "INFO: Running updates"
sudo yum update -y
sleep 1
echo "INFO: Adding EPEL repo"
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sleep 1
echo "INFO: Installing Kinesis agent"
sudo yum localinstall –y https://s3.amazonaws.com/streaming-data-agent/aws-kinesis-agent-latest.amzn1.noarch.rpm
sleep 1
echo "INFO: Installing daq package"
sudo yum localinstall -y https://www.snort.org/downloads/archive/snort/daq-2.0.6-1.f21.x86_64.rpm
sleep 1
echo "INFO: Installing snort package"
sudo yum localinstall -y https://www.snort.org/downloads/archive/snort/snort-openappid-2.9.9.0-1.f21.x86_64.rpm
sleep 1
echo "INFO: Installing snort community rules"
sudo wget -nv https://www.snort.org/downloads/community/community-rules.tar.gz -O /var/tmp/community-rules.tar.gz
sudo gunzip /var/tmp/community-rules.tar.gz
sudo tar -C /var/tmp -xvf /var/tmp/community-rules.tar
sudo cp /var/tmp/community-rules/* /etc/snort/rules/
sudo chmod 5775 /var/log/snort
sleep 1
echo "INFO: Enabling services"
sudo chkconfig snortd on
sudo chkconfig aws-kinesis-agent on
echo "INFO: done."