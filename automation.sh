#!/bin/bash

#S3 Variable Define
s3_bucket=upgrad-manav

#Performing an update of the package details
sudo apt update -y

#Install the apache2 package if it is not already installed
for pkg in $package; do
    if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
        echo "$pkg is installed! skipping installation"
    else
        echo "$pkg is NOT installed! installing apache2"
        sudo apt install apache2 -y
    fi
done

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

#Check for inventory.html
table="Log Type\tTime Created\tType\tSize"
FileName="$myname-httpd-logs-$timestamp.tar"
if [ -e /var/www/html/inventory.html ]; then
    echo "inventory.html file already exists. Updating content now"
    echo -e "\n $(ls /tmp/$FileName | cut -d '-' -f 2-3)\t$timestamp\t$(ls /tmp/$FileName | awk -F . '{print $NF}')\t$(du -k /tmp/$FileName | cut -f1)" >> /var/www/html/inventory.html
else
    echo "inventory.html not found. creating one now.."
    echo -e $table > /var/www/html/inventory.html
    echo -e "\n $(ls /tmp/$FileName | cut -d '-' -f 2-3)\t/tmp/$timestamp\t$(ls /tmp/$FileName | awk -F . '{print $NF}')\t$(du -k /tmp/$FileName | cut -f1)" >> /var/www/html/inventory.html
fi

#CronJob
cronstatus=$(ls /etc/cron.d/ | grep 'automation' && echo 'yes' || echo 'no')
if [[ $cronstatus == "no" ]]; then
    echo "automation cron job not found, creating now."
    touch /etc/cron.d/automation
    echo "0 8 * * * root /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
else
    echo "automation cron job exists"
fi

