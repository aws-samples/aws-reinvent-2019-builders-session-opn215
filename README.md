# AWS Snort Demo

## Contents
README.md
cfn-template.yaml
scripts\snort-sensor.sh
scripts\traffic-generator.sh
etc\aws-kinesis\agent.json
etc\rc.d\init.d\snortd
etc\snort\snort.conf
etc\sysconfig\snort

```bash
.
|-- README.md                         <-- This instructions file
|-- cfn-template.yaml                 <-- Cloudformtation template for lab environment
|-- scripts                           <-- Directory for linux build scripts
|   |-- snort-sensor.sh               <-- Installation script for snort packages
|   |-- traffic-generator.sh          <-- Instalation script for traffic generator
|-- etc                               <-- Directory for linux init and conf scripts
|   |-- aws-kinesis                   <-- Directory for aws-kinesis configuration
|   |   |-- agent.json                <-- Kinesis firehose agent configuration file
|   |-- rc.d                          <-- Directory for init scripts
|   |   |-- init.d                    <-- Directory for init scripts
|   |   |   |-- snortd                <-- Snort init script
|   |-- snort                         <-- Directory for snort configuration
|   |   |-- snort.conf                <-- Snort configuration file
|   |-- sysconfig                     <-- Directory for init scripts
|   |   |-- snort                     <-- Snort init script
```

## Description
This project builds a simple infrastructure for installing Snort and processing the log files with Kinesis Firehose.

## A. Deploy the stack
1. Log on to the AWS console and open CloudFormation.  Make sure that your current region is us-east-1, North Virginia.
2. Select the *Stacks* menu item in the side window.  Click on the *Create Stack* button.
3. In the *Specify Template* page, navigate to the *specify a template* section and select the option to *upload a template file*.
4. Select the *choose file* button, navigate to te directory where you downloaded the package and select the *cfn-template.yaml* file, then click on the *open* button.  Click on the *next* button to continue.
5. In the *Stack Details* page, set the stack name to *aws-snort-demo*.  Look through the template parameters for your information, then click on the *next* button to continue.
6. In the *configure stack options* page, accept the defaults and click on the *next* buttont to continue.  
7. In the *review aws-snort-demo* page, scroll to the bottom of the page and make sure that the tickbox *I acknowledge that AWS CloudFormation might create IAM resources with custom names* is ticked.  Click on the *create stack* button continue.

## B. Open a shell session to the Snort Sensor
1. In the AWS Console, open the *System Manager* console.
2. Select *Session Manager* in the menu in the left hand window.
3. Click on the *Start Session* button in the right hand window.
4. Click on the *radio button* for the *SnortSensor* EC2 instance. 
5. Click on the *start session* button.
6. Review the cloud-init script output to verify that the installation was sucessful.
```
cat /var/log/cloud-init-output.log | more
```

## C. Download tools package
1. In the AWS Console, open the *System Manager* console.
2. Select *Session Manager* in the menu in the left hand window.
3. Click on the *Start Session* button in the right hand window.
4. Click on the *radio button* for the *SnortSensor* EC2 instance. 
5. Click on the *start session* button.
6. Navigate to the ssm-user home directory and run the following commands
```
cd ~
sudo yum install -y git
git clone https://github.com/waymousa/aws-reinvent-2019-builders-session-opn215.git
cd aws-reinvent-2019-builders-session-opn215

```

## D. Install Kinesis Agent and Snort agent
1. In the AWS Console, open the *System Manager* console.
2. Select *Session Manager* in the menu in the left hand window.
3. Click on the *Start Session* button in the right hand window.
4. Click on the *radio button* for the *SnortSensor* EC2 instance. 
5. Click on the *start session* button.
6. Navigate to the ssm-user home directory and run the following commands
```
cd ~
cd aws-reinvent-2019-builders-session-opn215
cd scripts
chmod +x *.*
./snort-install.sh
./snort-configure.sh
```

## E. Validate Snort installation
1. In the AWS Console, open the *System Manager* console.
2. Select *Session Manager* in the menu in the left hand window.
3. Click on the *Start Session* button in the right hand window.
4. Click on the *radio button* for the *SnortSensor* EC2 instance. 
5. Click on the *start session* button.
6. Navigate to the ssm-user home directory and run the following commands
```
sudo snort -T -c /etc/snort/snort.conf
```

## E. Start Snort and Kinesis agents
1. In the AWS Console, open the *System Manager* console.
2. Select *Session Manager* in the menu in the left hand window.
3. Click on the *Start Session* button in the right hand window.
4. Click on the *radio button* for the *SnortSensor* EC2 instance. 
5. Click on the *start session* button.
6. Navigate to the ssm-user home directory and run the following commands
```
sudo service aws-kinesis-agent start
sudo service snortd start
```

## Install Snort and Kinesis Firehose agent
1. In the AWS Console, open the *System Manager* console.
2. Select *Run Command* in the menu in the left hand window.
3. Click on the *Run Command* button in the right hand window.
4. Type *AWS-RunShellScript* in the search bar and press the *return* key.
5. Click on the *radio button* for the *AWS-RunShellScript* document. 
6. Scroll down to the *Command parameters* section.  Copy and paste the contents of the *snort-sensor.sh* into this field.
```
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
```
7. Scroll down to the *targets* section.  In the specify instance tags fields, insert the following values, then click  on the *Add* button.
Field  | Value
------------- | -------------
Key  | SSMType
Value  | SnortSensor
8. In the *output option* section, ensure that the tickbox *Enable writing to S3 bucket* is ticked.  Select the radio button *choose a bucket name from the list*.  Click on the dropdown list and select the bucket with the name beginning with *aws-snort-demo-ssmloggingbucket*. 
9. Click on the *run* button.



## Configure snort
1. In the AWS Console, open the *System Manager* console.
2. Select *Session Manager* in the menu in the left hand window.
3. Click on the *Start Session* button in the right hand window.
4. Click on the *radio button* for the *SnortSensor* EC2 instance. 
5. Click on the *start session* button.
6. Navigate to the ssm-user home directory and runn the following commands
```
cd ~
sudo yum install git
git clone https://github.com/waymousa/aws-reinvent-2019-builders-session-opn215.git
cd aws-reinvent-2019-builders-session-opn215

```

## Delete the stack
1. In the AWS console, open the S3 console.
2. Select the bucket with the name beginning with *aws-snort-demo-ssmloggingbucket*.
3. Delete the bucket.
4. In the AWS console, open CloudFormation.  Make sure that your current region is us-east-1, North Virginia.
5. Select the *Stacks* menu item in the side window.  Select the stack named *aws-snort-demo*.  Click on the *delete* button.
