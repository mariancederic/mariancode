#!/bin/bash
#if [ -z "$1" ]; then
#	os="otro"
#fi
#clear
#echo "ispconfig en centos-7"
echo "Espero hayas hecho una instalacion minima"
#echo
#setenforce 0
#if [ `egrep -c ^SELINUX=enforcing /etc/sysconfig/selinux` -ne 0 ]; then
#        sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/sysconfig/selinux
#fi
#if [ `egrep -c ^SELINUX=enforcing /etc/selinux/config` -ne 0 ]; then
#	sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
#fi
#
#if [ $(mount |egrep "/ " |egrep -c xfs) -ne 0 ]; then
#	echo "Para activar quotas edita /etc/default/grub"
#	echo "y agrega: rootflags=uquota,gquota al final de GRUB_CMDLINE_LINUX"
#	echo "luego grub2-mkconfig -o /boot/grub2/grub.cfg"
#	echo "y reinicia y vuelve a ejecutar este script"
#	echo
#fi
#echo "Presiona ENTER si quieres continuar, o CTRL C para abortar"
#read
#yum -y update
#yum -y install firewalld wget screen epel-release yum-priorities quota which rsync centos-release-scl

#systemctl enable --now firewalld.service
#firewall-cmd --zone=public --add-port 443/tcp --add-port 80/tcp --zone=public --add-port 8080/tcp --zone=public --add-port 25/tcp --zone=public --add-port 110/tcp --add-port 22/tcp --add-port 143/tcp --add-port 21/tcp --add-port 587/tcp --permanent
#firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -p TCP --dport 21 --sport 1024:65534 -j ACCEPT
#firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -p TCP --dport 30000:50000 --sport 1024:65534 -j ACCEPT

#firewall-cmd --reload

#touch /usr/bin/cron
#chmod +x /usr/bin/cron

#sed -i s/enabled=1/enabled=0/g /etc/yum.repos.d/epel.repo

#yum clean all

#yum --enablerepo=epel -y install clamav-server-systemd clamav-server net-tools NetworkManager-tui ntp httpd mod_ssl mariadb-server php php-mysql php-mbstring phpmyadmin dovecot dovecot-mysql dovecot-pigeonhole postfix postgrey getmail amavisd-new spamassassin clamav clamd clamav-update unzip bzip2 perl-DBD-mysql php php-gd php-imap php-ldap php-mysql php-odbc php-pear php-xml php-xmlrpc php-pecl-apc php-mbstring php-mcrypt php-mssql php-snmp php-soap php-tidy curl curl-devel perl-libwww-perl ImageMagick libxml2 libxml2-devel mod_fcgid php-cli httpd-devel pure-ftpd openssl bind bind-utils webalizer awstats perl-DateTime-Format-HTTP perl-DateTime-Format-Builder fail2ban rkhunter mailman roundcubemail python-certbot-apache rh-php73-php-soap rh-php73-php-pear rh-php73-php-xmlrpc rh-php73-php-opcache rh-php73-php-mbstring rh-php73-php-intl rh-php73-php-gd rh-php73-php-fpm rh-php73-php-cli rh-php73-php-mysqlnd

#touch /etc/dovecot/dovecot-sql.conf
#ln -s /etc/dovecot/dovecot-sql.conf /etc/dovecot-sql.conf

#ln -s /etc/clamd.d/amavisd.conf /etc/clamd.conf

#systemctl disable --now sendmail.service
#systemctl enable dovecot mariadb.service postfix.service clamd@amavis httpd.service amavisd.service
#systemctl restart clamd@amavis dovecot mariadb.service postfix.service httpd.service

#echo "················ mysql_secure_installation ··············"
#mysql_secure_installation

wget -O /etc/httpd/conf.d/phpMyAdmin.conf https://www.ecualinux.com/ispconfig7/phpMyAdmin.conf --no-check-certificate
wget -O /etc/httpd/conf.d/ssl.conf https://www.ecualinux.com/ispconfig7/ssl.conf --no-check-certificate
wget -O /etc/phpMyAdmin/config.inc.php https://www.ecualinux.com/ispconfig7/config.myadmin --no-check-certificate
wget -O /etc/freshclam.conf https://www.ecualinux.com/ispconfig7/freshclam.conf --no-check-certificate
wget -O /etc/php.ini https://www.ecualinux.com/ispconfig7/php.txt --no-check-certificate

sa-update
freshclam

#yum -y install https://anku.ecualinux.com/7/x86_64/mod_suphp-0.7.2-1.el7.centos.x86_64.rpm --no-check-certificate

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
wget -O /etc/postfix/postgrey_whitelist_clients https://raw.githubusercontent.com/schweikert/postgrey/master/postgrey_whitelist_clients --no-check-certificate
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
