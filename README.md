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

## E. Validate Snort configuration
1. In the AWS Console, open the *System Manager* console.
2. Select *Session Manager* in the menu in the left hand window.
3. Click on the *Start Session* button in the right hand window.
4. Click on the *radio button* for the *SnortSensor* EC2 instance. 
5. Click on the *start session* button.
6. Navigate to the ssm-user home directory and run the following commands
```
cd ~
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

## F. Validate Snort and Kinesis are running
1. In the AWS Console, open the *System Manager* console.
2. Select *Session Manager* in the menu in the left hand window.
3. Click on the *Start Session* button in the right hand window.
4. Click on the *radio button* for the *SnortSensor* EC2 instance. 
5. Click on the *start session* button.
6. Navigate to the ssm-user home directory and run the following commands
```
cd ~
tail -f /var/log/snort/alerts.csv
tail -f /var/log/aws-kinesis-agent/aws-kinesis-agent.log
```
### Common issues
#### ResourceNotFoundException
The kinesis agent configuration file is hard coded to use the us-east-1 region endpoint.  If you see the 
ResourceNotFoundException then you need to update the agent.json file with the url for your regional endpoint.  
```
com.amazon.kinesis.streaming.agent.tailing.AsyncPublisher [ERROR] AsyncPublisher[fh:aws-snort-demo-SnortPacketStream:/var/log/snort/tcpdump.log*]:RecordBuffer(id=20,records=500,bytes=49831) Retriable send error (com.amazonaws.services.kinesisfirehose.model.ResourceNotFoundException: Firehose aws-snort-demo-SnortPacketStream not found under account 566240252914. (Service: AmazonKinesisFirehose; Status Code: 400; Error Code: ResourceNotFoundException; Request ID: c45880cc-174a-be21-9200-59038190176e)). Will retry.
```

## Z. Delete the stack
1. In the AWS console, open the S3 console.
2. Select and delete the buckets with names beginning with *aws-snort-demo*.
3. In the AWS console, open CloudFormation.  Make sure that your current region is us-east-1, North Virginia.
4. Select the *Stacks* menu item in the side window.  Select the stack named *aws-snort-demo*.  Click on the *delete* button.
