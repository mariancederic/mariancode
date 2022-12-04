#!/bin/bash

wget -O /etc/httpd/conf.d/phpMyAdmin.conf https://www.ecualinux.com/ispconfig7/phpMyAdmin.conf --no-check-certificate
wget -O /etc/httpd/conf.d/ssl.conf https://www.ecualinux.com/ispconfig7/ssl.conf --no-check-certificate
wget -O /etc/phpMyAdmin/config.inc.php https://www.ecualinux.com/ispconfig7/config.myadmin --no-check-certificate
wget -O /etc/freshclam.conf https://www.ecualinux.com/ispconfig7/freshclam.conf --no-check-certificate
wget -O /etc/php.ini https://www.ecualinux.com/ispconfig7/php.txt --no-check-certificate

sa-update
freshclam

#yum -y install https://anku.ecualinux.com/7/x86_64/mod_suphp-0.7.2-1.el7.centos.x86_64.rpm

#wget -q -O /etc/suphp.conf https://www.ecualinux.com/ispconfig7/suphp.conf --no-check-certificate
#wget  -q -O /etc/httpd/conf.d/mod_suphp.conf https://www.ecualinux.com/ispconfig7/mod_suphp.conf --no-check-certificate
wget  -q -O /etc/httpd/conf.d/php.conf https://www.ecualinux.com/ispconfig7/php.conf --no-check-certificate

#chmod +s /usr/sbin/suphp

systemctl enable --now rh-php73-php-fpm
systemctl enable --now httpd.service 
systemctl enable --now pure-ftpd.service

mkdir -p /etc/ssl/private/
openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem -subj '/CN=localhost.localdomain/O=My Company Name LTD./C=EC'
chmod 600 /etc/ssl/private/pure-ftpd.pem
cat "PassivePortRange          30000 50000" >> /etc/pure-ftpd/pure-ftpd.conf
systemctl restart pure-ftpd.service

wget -q -O /etc/named.conf https://www.ecualinux.com/ispconfig7/named.conf --no-check-certificate
touch /etc/named.conf.local
#fail2ban
wget -q -O /etc/fail2ban/jail.d/00-firewalld.conf https://www.ecualinux.com/ispconfig7/00-firewalld.conf --no-check-certificate
wget -q -O /etc/fail2ban/jail.d/postfix.local https://www.ecualinux.com/ispconfig7/postfix.local --no-check-certificate
wget -q -O /etc/fail2ban/jail.d/sshd.local https://www.ecualinux.com/ispconfig7/sshd.local --no-check-certificate

systemctl enable --now named.service
systemctl enable --now fail2ban.service

touch /var/lib/mailman/data/aliases
wget  -q -O /etc/roundcubemail/config.inc.php https://www.ecualinux.com/ispconfig7/config.rc --no-check-certificate
wget  -q -O /tmp/rcm.sql https://www.ecualinux.com/ispconfig7/rcm.sql --no-check-certificate

echo "Entre la clave de root de MySQL"
mysql -u root -p < /tmp/rcm.sql

wget -O /etc/httpd/conf.d/roundcubemail.conf https://www.ecualinux.com/ispconfig7/roundcubemail.conf.local --no-check-certificate

cat /etc/roundcubemail/config.inc.php|egrep -v enable_installer > /tmp/config.inc.php
cat /tmp/config.inc.php > /etc/roundcubemail/config.inc.php

systemctl restart httpd.service

cd /tmp
wget https://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz --no-check-certificate
tar xfz ISPConfig-3-stable.tar.gz
cd ispconfig3_install/install/

php -q install.php
wget -O /usr/lib/mailman/Mailman/mm_cfg.py https://www.ecualinux.com/ispconfig7/mm_cfg.py --no-check-certificate
chown root.mailman /usr/lib/mailman/Mailman/mm_cfg.py

#systemctl restart mailman

rm -rf /tmp/ispconfig3_install /tmp/*.rpm /tmp/ispconfig.tar.gz
cd /usr/local/ispconfig/server/scripts
wget https://www.ispconfig.org/downloads/ispconfig_patch --no-check-certificate
chmod 700 ispconfig_patch
chown root:root ispconfig_patch
ln -s /usr/local/ispconfig/server/scripts/ispconfig_patch /usr/local/bin/ispconfig_patch
wget -O /etc/postfix/master.cf https://www.ecualinux.com/ispconfig7/master.cf --no-check-certificate
wget -O /etc/postfix/main.cf https://www.ecualinux.com/ispconfig7/main.cf --no-check-certificate
openssl req -new -outform PEM -out /etc/postfix/smtpd.cert -newkey rsa:2048 -nodes -keyout /etc/postfix/smtpd.key -keyform PEM -days 365 -x509 -subj '/CN=localhost.localdomain/O=My Company Name LTD./C=EC'

wget -O /etc/sysconfig/postgrey https://www.ecualinux.com/ispconfig7/postgrey.txt --no-check-certificate
wget -O /etc/postfix/postgrey_whitelist_clients https://raw.githubusercontent.com/schweikert/postgrey/master/postgrey_whitelist_clients
#wget -O /usr/local/ispconfig/server/conf-custom/vhost.conf.master https://www.ecualinux.com/ispconfig7/vhost.conf.master --no-check-certificate
#chmod 760 /usr/local/ispconfig/server/conf-custom/vhost.conf.master
#chown root.root /usr/local/ispconfig/server/conf-custom/vhost.conf.master

systemctl enable postgrey httpd
systemctl restart postgrey postfix dovecot
systemctl reload httpd

yum -y erase NetworkManager*

rm -f /usr/bin/cron

echo "Vete al ispconfig System -> Aditional PHP versions y agrega una nueva"
echo "PHPName: rh-php73"
echo "PHP CGI: /opt/rh/rh-php73/root/usr/bin/php-cgi * /etc/opt/rh/rh-php73"
echo "PHP-FPM: rh-php73-php-fpm * /etc/opt/rh/rh-php73 * /etc/opt/rh/rh-php73/php-fpm.d"
