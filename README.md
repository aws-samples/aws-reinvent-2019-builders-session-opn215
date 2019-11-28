# AWS Snort Demo

## Description
This project builds a simple infrastructure for installing Snort and processing the log files with Kinesis Firehose.

## Contents
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

## A. Deploy the stack
1. Log on to the AWS console and open CloudFormation.  Make sure that your current region is **us-east-1**, North Virginia.
2. Select the **Stacks** menu item in the side window.  Click on the **Create Stack** button.
3. In the **Specify Template** page, navigate to the **specify a template** section and select the option to **upload a template file**.
4. Select the **choose file** button, navigate to te directory where you downloaded the package and select the **cfn-template.yaml** file, then click on the **open** button.  Click on the **next** button to continue.
5. In the **Stack Details** page, set the stack name to **aws-snort-demo**.  Look through the template parameters for your information, then click on the **next** button to continue.
6. In the **configure stack options** page, accept the defaults and click on the *next* buttont to continue.  
7. In the **review aws-snort-demo** page, scroll to the bottom of the page and make sure that the tickbox **I acknowledge that AWS CloudFormation might create IAM resources with custom names** is ticked.  Click on the **create stack** button continue.

## B. Open a shell session to the Snort Sensor
1. In the AWS Console, open the **System Manager** console.
2. Select **Session Manager** in the menu in the left hand window.
3. Click on the **Start Session** button in the right hand window.
4. Click on the **radio button** for the **SnortSensor** EC2 instance. 
5. Click on the **start session** button.
6. Review the cloud-init script output to verify that the installation was sucessful.
```
cat /var/log/cloud-init-output.log | more
```

## C. Download tools package
1. In the AWS Console, open the **System Manager** console.
2. Select **Session Manager** in the menu in the left hand window.
3. Click on the **Start Session** button in the right hand window.
4. Click on the **radio button** for the **SnortSensor** EC2 instance. 
5. Click on the **start session** button.
6. Navigate to the ssm-user home directory and run the following commands
```
cd ~
sudo yum install -y git
git clone https://github.com/waymousa/aws-reinvent-2019-builders-session-opn215.git
cd aws-reinvent-2019-builders-session-opn215

```

## D. Install Kinesis Agent and Snort agent
1. In the AWS Console, open the **System Manager** console.
2. Select **Session Manager** in the menu in the left hand window.
3. Click on the **Start Session** button in the right hand window.
4. Click on the **radio button** for the **SnortSensor** EC2 instance. 
5. Click on the **start session** button.
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
1. In the AWS Console, open the **System Manager** console.
2. Select **Session Manager** in the menu in the left hand window.
3. Click on the **Start Session** button in the right hand window.
4. Click on the **radio button** for the **SnortSensor** EC2 instance. 
5. Click on the **start session** button.
6. Navigate to the ssm-user home directory and run the following commands
--
cd ~
sudo snort -T -c /etc/snort/snort.conf
--

## E. Start Snort and Kinesis agents
1. In the AWS Console, open the *System Manager* console.
2. Select **Session Manager** in the menu in the left hand window.
3. Click on the **Start Session** button in the right hand window.
4. Click on the **radio button** for the **SnortSensor** EC2 instance. 
5. Click on the **start session** button.
6. Navigate to the ssm-user home directory and run the following commands
```
cd ~
sudo service aws-kinesis-agent start
sudo service snortd start
```

## F. Validate Snort and Kinesis are running
1. In the AWS Console, open the **System Manager** console.
2. Select **Session Manager** in the menu in the left hand window.
3. Click on the **Start Session** button in the right hand window.
4. Click on the **radio button** for the **SnortSensor** EC2 instance. 
5. Click on the **start session** button.
6. Navigate to the ssm-user home directory and run the following commands
```
cd ~
tail -f /var/log/snort/alerts.csv
tail -f /var/log/aws-kinesis-agent/aws-kinesis-agent.log
```
7. **Whoohoo!**  You now have a Snort sensor streaming alert and packet data into the Cloud!  This also works equally well for Snort senspors deployed on premsis that are managed.
---
### Common issues
#### ResourceNotFoundException
The kinesis agent configuration file is hard coded to use the us-east-1 region endpoint.  If you see the 
ResourceNotFoundException then you need to update the agent.json file with the url for your regional endpoint.  
```
com.amazon.kinesis.streaming.agent.tailing.AsyncPublisher [ERROR] AsyncPublisher[fh:aws-snort-demo-SnortPacketStream:/var/log/snort/tcpdump.log*]:RecordBuffer(id=20,records=500,bytes=49831) Retriable send error (com.amazonaws.services.kinesisfirehose.model.ResourceNotFoundException: Firehose aws-snort-demo-SnortPacketStream not found under account 566240252914. (Service: AmazonKinesisFirehose; Status Code: 400; Error Code: ResourceNotFoundException; Request ID: c45880cc-174a-be21-9200-59038190176e)). Will retry.
```
---


## G. Query Snort data with Athena
1. In thwe AWS Console, open the **S3** service.
2. Copy the name of he S3 buckect that starts with **aws-snort-demo-AthenaQueryResultsBucket**.  Also copy the anme of the bucket beginning with **aws-snort-demo-snortalertdata**.  You will need these later.
3. In the AWS Console, open the **Athena** console.
4. Click on the **Get Started** link.
5. Click on the link to **set up a query result location in Amazon S3**. 
6. Select the **s3://<your athena query bucket here>/results/**.
7. In the left had window, select the linke **Create Table - from S3 bucket data**.
8. In the **Databases > Add table** page, set the new **database** name to **SnortAlertData**.
9. Set the table name to **snort_alerts**.
10. Set the **Location of input data set** to the S3 bucket containing the snort alert data.  Click on the **next** button.
11. Set the **data format** radio button to **CSV** and click on the next button.
12.  Add the data columns for the snort csv data.  Se;lect the b utton to **bulk add columns** and paste int he strign below:
```
timestamp string, sig_generator string, sig_id string, sig_rev string, msg string, proto string, src string, srcport string, dst string, dstport string, ethsrc string, ethdst string, ethlen string, tcpflags string, tcpseq string, tcpack string, tcplen string, tcpwindow string, ttl string, tos string, id string, dgmlen string, iplen string, icmptype string, icmpcode string, icmpid string, icmpseq string
```
13. Click the **next** button to continue.  You will now see the **configure partitions** page.
14. You will now see the **configure partitions** page.  Click on the button to ***create table***.
15.  You will be returned to the Athena query console.  Select the **SnortAlertData** databasein the left have drop down list.  Click on the **run query** button to create the table.  You shoudl see a **query sucessful** message in the **results** window.
16. Run a simple query on your alert data as shown below:
```
select * from snort_alerts limit 1000
```
17. Save a copy of your query bu clicking on the **Save as** button.  Name your query **last-1k-snort-alerts** and add a description.  Click on the **save** button to continue.  Click on the **Saved queries** tab to check your query is listed.
17.  **Whoohoo!**  You can now perform adhoc queries on your Snort alert data using Athena!  Try out some different sample queries to see what you can discover about the network traffic hitting your server.

## H. Visualise Snort data in Quicksight
1. In thwe AWS Console, open the **Quicksight** service.
2. The first time you use this you will be asked to sign up.  Click on the **sign up for quicksight** button to continue.
3. You will see the licensing options, leatf the defaul of **Enterprise** and click the **continue** button.
4. Type <yourname>-aws-snort-demo-quicksight into the **Quicksight Account name** field
5. Type your email address into the **email** filed and click on the **finish** button.
6. After a short time you shoudl see the **Congratulations** page.  Click on the **go to Amazon quicksight** button to continue.
7. You will now see the Quciksight home page.  Click on the **new analysis** button to continue.
8. You will now see some default data sets.  Click on the **new data set** button to continue.
9. The **Create a Data Set** page will open.  Select the **Athena** button and type in the name **SnortAlertDataSource**.  Click on the **Create Data Source** button to continue.
10. You will now see the **choose your table** page.  Select **snortalertdata** from the **database** list.  Select **snort_alert** from the **table** list.  Click on the **select** button to continue.
11. The **finsih data set creation** page will be displayed.  Leave the default seting to import SPICE and click on the **visualise** button.
12. You may see no data at first, so click on the refresh import link to continue.  If you see a permission error then see the troubleshooting section below.  Whern the data appears int he SPICE page, select the save and visualise button to return to the visualization page.
13. In the **feilds list**, select **src** and **proto**.  Leave the **visual type** as **auto**.  You should noe have a barf chart showign you the top talkers to your server by protocol.
14. Select the top talker in the bar chart, then click on the **focus only on IP** setting.  You will now see only traffic from that single IP.
13. Whoohoo!  You can now visualise your alert data usign Quicksight!  Try our different graphs to identify the most common surce IP for alerts, protocol, and experiment with the feilds available to you.
### Common issues
#### Insufficient Permissions
Quicksight may not have all the permissions required to access the Snort data.  This may show up asn an error when you try to load the data set.  To resolve this, select the profile in the top right corner > manage quicksight > security & permissions.  Click ont eh button to add or remove Quicksight access to AWS services.  Untick the tickbox for Atehna, then tick it again.  When asked to set up access for S3 buckets, select the buckets you created for the snort aleert data and the athena query data.  Click on the update button to finish. 

## Z. Delete the stack
1. In the AWS console, open the S3 console.
2. Select and delete the buckets with names beginning with *aws-snort-demo*.
3. In the AWS console, open CloudFormation.  Make sure that your current region is us-east-1, North Virginia.
4. Select the *Stacks* menu item in the side window.  Select the stack named *aws-snort-demo*.  Click on the *delete* button.
