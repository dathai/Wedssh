#!/bin/bash

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
MYPORT="s/85/99/g";

# go to root
cd

#ca-certificates
apt-get install ca-certificates

# setting port ssh
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 443 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

# install squid3
cd
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/dathai/Wedssh/master/API/squid.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# install webserver
cd
apt-get -y install nginx php5 php5-fpm php5-cli php5-mysql php5-mcrypt
rm /etc/nginx/sites-enabled/default && rm /etc/nginx/sites-available/default
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
mv /etc/nginx/conf.d/vps.conf /etc/nginx/conf.d/vps.conf.backup
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/dathai/Wedssh/master/API/nginx.conf"
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/dathai/Wedssh/master/API/vps.conf"
sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
sed -i $MYPORT /etc/nginx/conf.d/vps.conf;
useradd -m vps && mkdir -p /home/vps/public_html
rm /home/vps/public_html/index.html && echo "<?php phpinfo() ?>" > /home/vps/public_html/info.php
chown -R www-data:www-data /home/vps/public_html && chmod -R g+rw /home/vps/public_html
service php5-fpm restart && service nginx restart

# install myweb
cd /home/vps/public_html/
wget -O /home/vps/public_html/myweb.tar "https://raw.githubusercontent.com/dathai/Wedssh/master/API/myweb.tar"
cd /home/vps/public_html/
tar xf myweb.tar

# Setting web
echo -e "\033[01;31mIP User And Pass 'ROOT' Only \033[0m"
read -p "IP : " MyIPD
read -p "Username : " Login
read -p "Password : " Passwd
MYIPS="s/xxxxxxxxx/$MyIPD/g";
US1="s/arch19user/$Login/g";
PS2="s/arch19pass/$Passwd/g";
sed -i $MYIPS /home/vps/public_html/index.php;
sed -i $US1 /home/vps/public_html/index.php;
sed -i $PS2 /home/vps/public_html/index.php;

#FIGlet In Linux
sudo apt-get install figlet
yum install figlet

#RM file
rm -f myweb.tar
cd
rm -f install.sh

# About
clear
figlet "THAI-VPN"
echo "Script WebSSH Auto Install"
echo "-Web Server"
echo "-Squid Proxy Port 80,8080,3128"
echo "Squid     :  http://$MYIP:8080"
echo "Nginx      :  http://$MYIP:99"
echo "Web    :  http://$MYIP:99"
