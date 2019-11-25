# AWS Snort Demo

## Contents
* README.md
* cfn-template.yaml
* scripts\snort-sensor.sh
* scripts\traffic-generator.sh
* etc\aws-kinesis\agent.json
* etc\rc.d\init.d\snortd
* etc\snort\snort.conf
* etc\sysconfig\snort

## Description
This project builds a simple infrastructure for installing Snort and processing the log files with Kinesis Firehose.

## Deploy the stack
1. Log on to the AWS console and open CloudFormation.  Make sure that your current region is us-east-1, North Virginia.
2. Select the * Stacks * menu item in the side window.  Click on the * Create Stack * button.
3. In the * Specify Template * page, navigate to the * specify a template * section and select the option to * upload a template file *.
4. Select the * choose file * button, navigate to te directory where you downloaded the package and select the * cfn-template.yaml * file, then click on the * open * button.  Click on teh * next 8 button to continue.
5. In the * Stack Details * page, set the stack name to * aws-snort-demo *.  Look through the template parameters for your information, then click on the * next * button to continue.
6. In the * configure stack options * page, accept the defaults and click on the * next * buttont to continue.  
7. In the * review aws-snort-demo * page, scroll to the bottom of the page and make sure that the tickbox * I acknowledge that AWS CloudFormation might create IAM resources with custom names * is ticked.  Click on the * create stack * button continue.

## Install Snort Sensor packages

