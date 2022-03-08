#!/bin/bash

#S3 Variable Define
s3_bucket=upgrad-manav

#Performing an update of the package details
sudo apt update -y

#Install the apache2 package if it is not already installed
sudo apt install apache2
sudo systemctl start apache2

#Ensure the apache2 service is running
sudo systemctl enable apache2.service

#Create a tar archive
timestamp=$(date '+%d%m%Y-%H%M%S')
myname=manav
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/access.log /var/log/apache2/error.log

# Installing awscli
sudo apt update
sudo apt install awscli

#Copy the archive to S3
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
