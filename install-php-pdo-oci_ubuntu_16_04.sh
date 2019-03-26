#!/bin/bash -x

# Downloads to $DIR_FILES
# instantclient-basic-linux.x64-12.1.0.2.0.zip
# instantclient-sdk-linux.x64-12.1.0.2.0.zip

if ["`id -u`" -ne 0]; then
    exit 0;
fi

DIR_FILES=/root/downloads

apt-get remove --purge apache2 apache2-bin apache2-data apache2-utils libapache2-mod-php5.6

add-apt-repository ppa:ondrej/php
apt-get update
apt-get install -y build-essential nginx autoconf automake libtool m4 libaio1 unzip php-pear php5.6 php5.6-common php5.6-cli php5.6-dev php5.6-fpm php5.6-cli php5.6-gd php5.6-json php5.6-mbstring php5.6-readline php5.6-xml pkg-php-tools

mkdir -p $DIR_FILES

cd $DIR_FILES

wget http://pecl.php.net/get/oci8-2.0.12.tgz

mkdir -p /opt/oracle/

unzip $DIR_FILES/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle
unzip $DIR_FILES/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle

ln -sf /opt/oracle/instantclient_12_1/libclntsh.so.12.1 /opt/oracle/instantclient_12_1/libclntsh.so
ln -sf /opt/oracle/instantclient_12_1/libocci.so.12.1 /opt/oracle/instantclient_12_1/libocci.so

ldconfig

#Use the OCI8 extension to access Oracle Database. Use 'pecl install
#oci8' to install for PHP 7. Use 'pecl install oci8-2.0.12' to install
#for PHP 5.2 - PHP 5.6. Use 'pecl install oci8-1.4.10' to install for
#PHP 4.3.9 - PHP 5.1. The OCI8 extension can be linked with Oracle
#client libraries from Oracle Database 12, 11, or 10.2.

pecl install oci8-2.0.12

#When you are prompted for the Instant Client location, enter the following:
#instantclient,/opt/oracle/instantclient_12_1

echo "extension=oci8.so" > /etc/php/5.6/mods-available/oci8.ini
ln -sf /etc/php/5.6/mods-available/oci8.ini /etc/php/5.6/fpm/conf.d/30-oci8.ini
ln -sf /etc/php/5.6/mods-available/oci8.ini /etc/php/5.6/cli/conf.d/30-oci8.ini

# Config PATH:
#/opt/oracle/instantclient_12_1/network/admin/tnsnames.ora

# Restart
service php5.6-fpm restart
