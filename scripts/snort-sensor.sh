#!/bin/bash -xe
sudo yum update -y
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install –y https://s3.amazonaws.com/streaming-data-agent/aws-kinesis-agent-latest.amzn1.noarch.rpm
sudo yum install -y https://www.snort.org/downloads/archive/snort/daq-2.0.6-1.f21.x86_64.rpm
sudo yum install -y https://www.snort.org/downloads/archive/snort/snort-openappid-2.9.9.0-1.f21.x86_64.rpm
sudo wget -nv https://www.snort.org/downloads/community/community-rules.tar.gz -O /var/tmp/community-rules.tar.gz
sudo gunzip /var/tmp/community-rules.tar.gz
sudo tar -C /var/tmp -xvf /var/tmp/community-rules.tar
sudo cp /var/tmp/community-rules/* /etc/snort/rules/
sudo chmod 5775 /var/log/snort
sudo chkconfig snortd on
sudo chkconfig aws-kinesis-agent on