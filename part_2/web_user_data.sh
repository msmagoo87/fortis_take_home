#!/bin/bash

sudo dnf update -y
sudo dnf install -y httpd
sudo systemctl start httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
echo "<html><body><h1>It Works!</h1></body></html>" > /var/www/html/index.html
sudo sed -i '/Listen 80/a Listen 8080' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd