# Intelligent Automation with AWS and Snort IDS

## Description
This project demonstrates some of the ways to can add value to your existing Snort IDS system by integrating it with AWS.
Things you will explore include:
* Centralise and automate management of your Snort Sensors using a number of tools in the Systems Manager service
* Ingest Snort alert and packet data in a scalable, cost effective and secure manner with Kinesis Firehose
* Store your Snort Sensor data in a scalable and cost effective manner using Simple Storage Service S3
* Gain insights from your Snort data usign Analytics services Athena and Quicksight

---
![Architecture Diagram](images/Architecture.jpg "Architecture diagram")

---

## Contents
```
.
|-- README.md                         <-- This instructions file
|-- 1-image-builder-pipeline.yaml     <-- Cloudformation stack for the Image Builder Pipeline
|-- 2-snort-stack.yaml                <-- Cloudformtation stack for Snort sensor
|   |-- artifacts                     <-- Directory for deployment artifacts
|   |   |-- kinesis-install.sh        <-- Installation script for Kinesis using the 'expect' command
|   |   |-- SnortDemo-CodeDeploy.zip  <-- Zip of the codedeploy directory to import into CodeCommit
|-- codedeploy                        <-- Directory for CodeDeploy files
|   |-- agent.json                    <-- Kinesis firehose agent configuration file
|   |-- snortd                        <-- Snort init script
|   |-- snort.conf                    <-- Snort configuration file
|   |-- snort                         <-- Snort init script
|   |-- appspec.yml                   <-- CodeDeploy configuration script
|   |-- local.rules                   <-- Local rules for Snort
|   |-- community.rules               <-- Community rules for Snort
|   |-- black_list.rules              <-- Black List rules for Snort
|   |-- white_list.rules              <-- White List rules for Snort
|   |-- scripts                       <-- CodeDeploy scripts directory
|   |   |-- after_install.sh          <-- CodeDeploy post-installation script
|   |   |-- before_install.sh         <-- CodeDeploy pre-installation script
|   |   |-- start_server.sh           <-- CodeDeploy start server script
|   |   |-- stop_server.sh            <-- CodeDeploy stop server script
```

## Prerequisites
This section describes the pre-requisites you must have in order to sucessfully run this demo.
* An AWS Account and an IAM user with sufficient privilegses to run the CloudFormation scripts.
* A PC or Mac with Git installed and a Web Browser compatible with the AWS Console.
* The AWS CLI and AWS CLI Helper must be installed.  See these instructions for guidance on howe to [set up git](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-windows.html "set up git").

## A. Deploy the EC2 Image Pipeline stack
In this section we will use [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html "CloudFormation") to deploy [EC2 ImageBuilder](https://docs.aws.amazon.com/imagebuilder/latest/userguide/how-image-builder-works.html "EC2 ImageBuilder") Pipeline stack.  This includes all the components for a Snort Sensor recipe that ImageBuilder can run to produce an AMI.

---
![CloudFormation](images/CFN.png "CloudFormation")

---
1. Log on to the AWS console and open CloudFormation.  Make sure that your current region is **us-east-1**, North Virginia.
2. Select the **Stacks** menu item in the side window.  Click on the **Create Stack** button.
3. In the **Specify Template** page, navigate to the **specify a template** section and select the option to **upload a template file**.
4. Select the **choose file** button, navigate to te directory where you downloaded the package and select the **1-image-builder-pipeline.yaml** file, then click on the **open** button.  Click on the **next** button to continue.
5. In the **Stack Details** page, set the stack name to **ImageBuilderStack**.  Look through the template parameters for your information, then click on the **next** button to continue.
6. In the **configure stack options** page, accept the defaults and click on the *next* buttont to continue.  
7. In the **review ImageBuilderStack** page, scroll to the bottom of the page and make sure that the tickbox **I acknowledge that AWS CloudFormation might create IAM resources with custom names** is ticked.  Click on the **create stack** button continue.

---
### Points to note:
What does this ImageBuilder configuration do?  Its purpose is to generate a Golden Image of a Snort Sensor.  

First, you define the The Operating System you want to build, and for this lab we use the Amazon linux 2 image.  

Next, you define what software components you want to install on the base image.  For this lab we create components for:
* Code Deploy Agent
* DAQ
* EPEL Repository
* Git (not longer requires as the lab uses CodeDeploy instead)
* Oracle JDK
* Kinesis Agent
* Snort

Next, you define a recipie whic allows you to mix and match the components and base image to meet your requirements.

Lastly, you define a pipeline which actually builds the AMI and stores it in the private AMI store.

You can then use this new AMI to create instances.

---


## B. Run the EC2 Image Builder Pipeline
In this section we will run the EC2 Image Builder Pipline to create an AMI that includes the Snort and Kinesis packages along with all their dependancies.

---
![EC2 Image Builder](images/EC2ImageBuilder.png "EC2 Image Builder")

---
1. In the AWS Console, open the **EC2 Image Builder** console.
2. Select **Image pipelines** in the menu in the left hand window.
3. Select **SnortImagePipeline** in the right hand window.
4. Click on the **Actions** drop down and select **run pipeline** from the menu.
5. The Pipeline will now generate the AMI to be used to create our Snort Sensor.  After a short time the pipeline will complete.  If your Pipeline failes see the Points to note section below.
6. Navigate to the **EC2** service page and select **AMIs** from the **Images** section.  Verify that the filter dropdown is set to **Owned by Me**.
7. You should see an AMI named **SnortImage-uniqueid**.  Select this image and then copy the **AMI ID** listed in the **Details** tab.  Save this AMI ID value because you will need it for the next step.
8.  **Whoohoo!** you used EC2 Image Builder to create a Linux image with Snort installed.

---
### Points to note:
This AMI can be used in both AWS and on-premisis environments.  To run the image in on-premisis environments, see the documentation at this [link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/amazon-linux-2-virtual-machine.html "link").  You can also keep a watch on the AMI build process by navigating ot the **Systems Manager** in the console and selecting **Automations**.  You should see an automation that is progressing and it will take 10 minutes or so to complete.  The Log files for the automation will be stored in an S3 bucket **ImageBuilderStack-ssmloggingbucket-uniqueid** so you can analyse them for any issues.

---

## C. Deploy the Snort stack
In this section we will use CloudFormation to deploy the intial stack.  This includes all the infrastructure needed to get the basic environment working.  The diagram below represents the stack in is current form.

---
![CloudFormation](images/CFN.png "CloudFormation")

---
1. Log on to the AWS console and open [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html "CloudFormation").  Make sure that your current region is **us-east-1**, North Virginia.
2. Navigate to the **EC2** console.   
2. Select the **Stacks** menu item in the side window.  Click on the **Create Stack** button.
3. In the **Specify Template** page, navigate to the **specify a template** section and select the option to **upload a template file**.
4. Select the **choose file** button, navigate to te directory where you downloaded the package and select the **2-snort-stack.yaml** file, then click on the **open** button.  Click on the **next** button to continue.
5. In the **Stack Details** page, set the stack name to **SnortStack**.  Set the **LinuxImageId** paremeter to uise the **AMI ID** that you copied in the previous section.  Review the other template parameters for your information, then click on the **next** button to continue.
6. In the **configure stack options** page, accept the defaults and click on the *next* buttont to continue.  
7. In the **review SnortStack** page, scroll to the bottom of the page and make sure that the tickbox **I acknowledge that AWS CloudFormation might create IAM resources with custom names** is ticked.  Click on the **create stack** button continue.

---
### Points to note:
If you examine the Snort Sensor you will note that it has 3 network adapters configured.

* eth0 - default adapter for the EC2 instance running Snort
* eth1 - target adapter for the Traffic Mirror service used to decapsulate the VXLAN traffic on port 4789
* vxlan0 - used by Snort to examine the decapsulated packets

The vxlan01 adapter is not enabl;ed by default so the EC2 instance will not survive a reboot. Should you need to reboot the instance you will need to run thew following commands to re-enable the vxlan0 adapter.
```bash
sudo ip link add vxlan0 type vxlan id 1111 group 239.1.1.1 dev eth1 dstport 4789
sudo ip link set vxlan0 up
```

---

## D. Import the codedeploy artifacts to CodeCommit
---
In this section we will use [CodeCommit](https://aws.amazon.com/codecommit/ "CodeCommit") to store the Snort configuration rules we need to scan network traffic.  This approach allows you to version control your Snort configuration and enables automated deployment of the rules.  The instructions here are based on this [Tutorial](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-codecommit.html "Tutorial").
---
![Systems manager](images/systems-manager.jpg "Systems Manager")

---
1. In the AWS Console, open the **CodeDeploy** console.
2. Select **Source . CodeCommit** in the menu in the left hand window and then click on **Repositories**.
3. Click on the **Radio Button** button next to **SnortConfigRepo** and then click on the **View repository** button.  You will see that the repo currenty has no files in it.
4. Click on the **Clone Url button** for your repo and select **Clone HTTPS**.
5. Note the requirements: Git, codecommit user and AWS CLI Credential Helper.  To set all this up follow the instructions at this link [Set Up Git](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-windows.html "Set up Git").  DO NOT CLONE THE REPO YET!
6. Open a command line window on your PC and crate a temporary directory, for example c:\temp\snortdemo. Navigate to this directory.
7. Clone the repo to your temporary directory using the git clone command.  You woudl not see an empty repo called **SnortConfigRepo** in your temporary directory.
```bash
c:\\dev\\snort-demo\\SnortConfigRepo>git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/SnortConfigRepo

```

8. Download the zip file [SnortDemo-CodeDeploy.zip](https://github.com/aws-samples/aws-reinvent-2019-builders-session-opn215/blob/mainline/artifacts/SnortDemo-CodeDeploy.zip "SnortDemo-CodeDeploy.zip") and put it in the directory **c:\temp\snortdemo\SnortConfigRepo**.
9. Extract the file to this directory and verify that you can see the following contents
```bash
agent.json                    
snortd                       
snort.conf                  
snort                         
appspec.yml                   
local.rules               
community.rules             
black_list.rules              
white_list.rules             
scripts/after_install.sh                  
scripts/before_install.sh        
scripts/start_server.sh          
scripts/stop_server.sh          
```

10. Delete the zip file and then push the updated repo to the CodeCommit repository.
```bash
c:\\dev\snort-demo\\SnortConfigRepo>git add .
c:\\dev\snort-demo\\SnortConfigRepo>git commit -m "Intital load."
c:\\dev\snort-demo\\SnortConfigRepo>git push
```

11. In the AWS Console, navigate to the SnortConfigRepo CodeCommit repo to check the files are loaded.

## E. Deploy the Snort Configuration
---
In this section we will use [CodeDeploy](https://aws.amazon.com/codedeploy/ "CodeDeploy") to update the Snort and Kinesis agent copnfiguration using an artifact we store in [CodeCommit](https://aws.amazon.com/codecommit/ "CodeCommit"). This approach allows you to push configuration changes to all of the Snort sensors in your network based on the tag SSMType:SnortSensor.  The instructions here are based on this [Tutorial](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-codecommit.html "Tutorial").
---
![Systems manager](images/systems-manager.jpg "Systems Manager")

1. In the AWS Console, open the **CodeDeploy** console.
2. Select the **Pipeline . CodePipeline** item on the left hand side.
3. Select **Pipelines** and then select the **SnortConfigPipeline**.  It will show failed on the last run but we will fix that now.
4. Click on the **Release Change** button to restart the pipleine.
5. The Pipeline will now deploy the snort configuration to the snort sensor instances.

## E. Validate the Snort Configuration
---
Before we give our Snort server a clean bill of health we need to check that configuration is working ok.  Use the Session Manager to open a shell on the remote host and run the snort configuration check.

---
1. In the AWS Console, open the **System Manager** console.
2. Select **Session Manager** in the menu in the left hand window.
3. Click on the **Start Session** button in the right hand window.
4. Click on the **radio button** for the **SnortSensor** EC2 instance. 
5. Click on the **start session** button.
6. Navigate to the ssm-user home directory and run the following commands
```bash
sudo snort -T -c /etc/snort/snort.conf
```

## F. Validate Snort and Kinesis are running
1. In the AWS Console, open the **System Manager** console.
2. Select **Session Manager** in the menu in the left hand window.
3. Click on the **Start Session** button in the right hand window.
4. Click on the **radio button** for the **SnortSensor** EC2 instance. 
5. Click on the **start session** button.
6. Navigate to the ssm-user home directory and run the following commands
```bash
tail -f /var/log/snort/alerts.csv
tail -f /var/log/aws-kinesis-agent/aws-kinesis-agent.log
```
7. **Whoohoo!**  You now have a Snort sensor streaming alert and packet data into the Cloud!  This also works equally well for Snort senspors deployed on premsis that are managed.
---
### Common issues
#### ResourceNotFoundException
The kinesis agent configuration file is hard coded to use the us-east-1 region endpoint.  If you see the 
ResourceNotFoundException then you need to update the agent.json file with the url for your regional endpoint.  
```bash
com.amazon.kinesis.streaming.agent.tailing.AsyncPublisher [ERROR] AsyncPublisher[fh:aws-snort-demo-SnortPacketStream:/var/log/snort/tcpdump.log*]:RecordBuffer(id=20,records=500,bytes=49831) Retriable send error (com.amazonaws.services.kinesisfirehose.model.ResourceNotFoundException: Firehose aws-snort-demo-SnortPacketStream not found under account 566240252914. (Service: AmazonKinesisFirehose; Status Code: 400; Error Code: ResourceNotFoundException; Request ID: c45880cc-174a-be21-9200-59038190176e)). Will retry.
```
---
### POINT TO NOTE
The local.rules file that is used for this demo is VERY verbose.  Basically, its recording every network packet the Snort Sensor sees arriving on the host.  Thats a lot of packets!  To make this more sensible try forking the repo and creating your own local.rules file.  For the purposes of the demo its good to see the scalability of Snort, Kinesis, Athena and Quicksight in action but that local.rules files does not represent what you would normally do in a production environment.

---

## G. Query Snort data with Athena
---
We now have a large volume of Snort alert data and packet data arriving in our S3 buckets via Kinesis Firehose.  Its time to see how we can start runnign analytics on AWS to get insights from all that data.  First, we are going to set up Athena in this step so that we can run SQL queries across our log data and find out interesting things.

---
![Athena](images/Athena.png "Athena")

---
1. In the AWS Console, open the **S3** service.
2. Copy the name of the S3 bucket that starts with **SnortStack-AthenaQueryResultsBucket**.  Also copy the name of the bucket beginning with **SnortStack-snortalertdata**.  You will need these later.
3. In the AWS Console, open the **Athena** console.
4. Click on the **Get Started** link.
5. Click on the link to **set up a query result location in Amazon S3**. 
6. Select the **s3://*your athena query bucket here*/results/**.
7. In the left had window, select the link **Create Table - from S3 bucket data**.
8. In the **Databases > Add table** page, set the new **database** name to **SnortAlertData**.
9. Set the table name to **snort_alerts**.
10. Set the **Location of input data set** to the S3 bucket containing the snort alert data.  Click on the **next** button.
11. Set the **data format** radio button to **CSV** and click on the next button.
12.  Add the data columns for the snort csv data.  Select the b utton to **bulk add columns** and paste in the string below:
```
timestamp string, sig_generator string, sig_id string, sig_rev string, msg string, proto string, src string, srcport string, dst string, dstport string, ethsrc string, ethdst string, ethlen string, tcpflags string, tcpseq string, tcpack string, tcplen string, tcpwindow string, ttl string, tos string, id string, dgmlen string, iplen string, icmptype string, icmpcode string, icmpid string, icmpseq string
```
13. Click the **next** button to continue.  You will now see the **configure partitions** page.
14. You will now see the **configure partitions** page.  Click on the button to **create table**.
15.  You will be returned to the Athena query console.  You should see a **query sucessful** message in the **results** window.
16. Run a simple query on your alert data as shown below:
```sql
select * from snort_alerts limit 1000
```
17. Save a copy of your query by clicking on the **Save as** button.  Name your query **last-1k-snort-alerts** and add a description.  Click on the **save** button to continue.  Click on the **Saved queries** tab to check your query is listed.
17.  **Whoohoo!**  You can now perform adhoc queries on your Snort alert data using Athena!  Try out some different sample queries to see what you can discover about the network traffic hitting your server.

## H. Visualise Snort data in Quicksight
---
As you can see, its easy to get up and runing with Athena for ad-hoc queries of our Snort data.  Next, we will set up some visualisations for our data using Quicksight.

---
![Quicksight](images/Quicksight.png "Quicksight")

---
1. In thwe AWS Console, open the **Quicksight** service.
2. The first time you use this you will be asked to sign up.  Click on the **sign up for quicksight** button to continue.
3. You will see the licensing options, leave the default of **Enterprise** and click the **continue** button.
4. Type ***yourname*-aws-snort-demo-quicksight** into the **Quicksight Account name** field
5. Type your email address into the **email** field and click on the **finish** button.
6. After a short time you shoudl see the **Congratulations** page.  Click on the **go to Amazon quicksight** button to continue.
7. You will now see the Quicksight home page.  Click on the **new analysis** button to continue.
8. You will now see some default data sets.  Click on the **new data set** button to continue.
9. The **Create a Data Set** page will open.  Select the **Athena** button and type in the name **SnortAlertDataSource**.  Click on the **Create Data Source** button to continue.
10. You will now see the **choose your table** page.  Select **snortalertdata** from the **database** list.  Select **snort_alerts** from the **table** list.  Click on the **select** button to continue.
11. The **finish data set creation** page will be displayed.  Leave the default seting to import SPICE and click on the **visualise** button.
12. You may see no data at first, so click on the refresh import link to continue.  If you see a permission error then see the troubleshooting section below.  Whern the data appears in the SPICE page, select the save and visualise button to return to the visualization page.
13. In the **fields list**, select **src** and **proto**.  Leave the **visual type** as **auto**.  You should noe have a bar chart showing you the top talkers to your server by protocol.
14. Select the top talker in the bar chart, then click on the **focus only on IP** setting.  You will now see only traffic from that single IP.
13. **Whoohoo!**  You can now visualise your alert data using Quicksight!  Try our different graphs to identify the most common surce IP for alerts, protocol, and experiment with the fields available to you.
---
### Common issues
#### Insufficient Permissions
Quicksight may not have all the permissions required to access the Snort data.  This may show up as an error when you try to load the data set.  To resolve this, select the profile in the top right corner > manage quicksight > security & permissions.  Click on the button to add or remove Quicksight access to AWS services.  Untick the tickbox for Athena, then tick it again.  When asked to set up access for S3 buckets, select the buckets you created for the snort alert data and the athena query data.  Click on the update button to finish. You will return to the SPICE screen, select the **Save & Visualise** button.

---

## I. Create a Security operations centre
This step creates a SOC with a Kali Linux instance that you can use for penetration your environment, testing SNORT rules and scripting validation of your environment.  It used the Kali linux image so it requires an EC2 Keypair to get started, although you can integrate the Instance with Systems Manager for easy access as well.
1. Setup your workstation with an AWS-CLI profile that allows you to run commands against the account and region where you are builiding your Snort environment.
2. Create an EC2 keypair to use with the Kali instance. the example command below creates a key pair named *soc-kp* and saves the private key as a pem file in the c:\temp\ directory.
```bash
 aws ec2 create-key-pair --key-name soc-kp --query 'KeyMaterial' --output text > "c:\temp\soc.pem"
```
3. Log on to the AWS console and open CloudFormation.  Make sure that your current region is **us-east-1**, North Virginia.
4. Select the **Stacks** menu item in the side window.  Click on the **Create Stack** button.
5. In the **Specify Template** page, navigate to the **specify a template** section and select the option to **upload a template file**.
6. Select the **choose file** button, navigate to te directory where you downloaded the package and select the **4-soc-stack.yaml** file, then click on the **open** button.  Click on the **next** button to continue.
7. In the **Stack Details** page, set the stack name to **SOCStack**.  Look through the template parameters for your information, then click on the **next** button to continue.
8. In the **configure stack options** page, accept the defaults and click on the *next* buttont to continue.  
9. In the **review ImageBuilderStack** page, scroll to the bottom of the page and make sure that the tickbox **I acknowledge that AWS CloudFormation might create IAM resources with custom names** is ticked.  Click on the **create stack** button continue.
10. Once the stack is sucessfully created, navigate to the EC2 service in the AWS Console.  Navigate tot he Instances item int he left hand pane.  Locate the KaliSOCInstance in the right hand pane and click on the radion button to select it.  Make a note of the public DNS name and IP address.
11.  Using your ssh client sccess the server as ec2-user using the private key you created in step 2.
12.  Update the Kali instance by running the distribtuion update commands.  Warning, this will take a while and it is not silent so you will need to keep an eye on it to make sure it doesn't get stuck somewhere.
```bash
sudo su - 
apt update
apt upgrade
apt dist-upgrade
```


## Y. What next?
This lab is a basis for further exploration on the subject of how to get insights from your NIDS systems.  It highlighted the strenghts of using automation tools for deployign and managing Snort Sensors.  We explored how to run simple SQL querieis and generate visual reports.  Moving forward you can explore further automation ideas:
* Implement a CI/CD pipeline for Snort configuration management using CodePipeline
* Anomaly detection using Sagemaker
* Packet analysis using tcpdump tools or Kali Linux
* Leverage the Scapy library for python and use a traffic generator to test Snort rules

## Z. Delete the stack
1. In the AWS Console, Select EC2.  Select the SnortSensor instance and stop it.
2. In the AWS console, open the S3 console. Select and empty the buckets with names beginning with **SnortStack** and **ImageBuilderStack**.
3. In the AWS console, open CloudFormation.  Make sure that your current region is us-east-1, North Virginia.
4. Select the **Stacks** menu item in the side window.  Select the stacks named **SnortStack** and **ImageBuilderStack**.  Click on the **delete** button.
5. Select the **EC2 AMI Image** and click on **actions** drop down.  Select **Deregister**.
