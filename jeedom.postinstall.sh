#!/bin/bash


while true
do
	echo "please enter mysql host (default 127.0.0.1)"
	read MySQL_host
	[ -z ${MySQL_host} ] && MySQL_host="127.0.0.1"
        echo "please enter MySQL root password"
        read MySQL_root < /dev/tty
        echo "Is MySQL root password : "${MySQL_root}
        while true
        do
            echo -n "yes/no: "
            read ANSWER < /dev/tty
            case $ANSWER in
                        yes)
                                break
                                ;;
                        no)
                                break
                                ;;
            esac
            echo ""
        done
        if [ "${ANSWER}" = "yes" ]
	then
                # Test access immediately
                # to ensure that the provided password is valid
                CMD="`echo "show databases;" | mysql -uroot -p${MySQL_root} -h${MySQL_host}`"
                if [ $? -eq 0 ]; then
                        # good password
                        break
                else
                        echo "Bad Password or host"
                        continue
                fi
        fi
done

cd /srv/http/jeedom
#Configuration de la base de données
bdd_password=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 15)
echo "DROP USER 'jeedom'@'localhost';" > /tmp/mysql_install_$$.sql
echo "CREATE USER 'jeedom'@'localhost' IDENTIFIED BY '${bdd_password}';" >> /tmp/mysql_install_$$.sql
echo "DROP DATABASE IF EXISTS jeedom;" >> /tmp/mysql_install_$$.sql
echo "CREATE DATABASE jeedom;" >> /tmp/mysql_install_$$.sql
echo "GRANT ALL PRIVILEGES ON jeedom.* TO 'jeedom'@'localhost';" >> /tmp/mysql_install_$$.sql

mysql -u root -p${MySQL_root} -h${MySQL_host} < /tmp/mysql_install_$$.sql

rm -f /tmp/mysql_install_$$.sql

dateFic=$(date +%s)
phpIni=/etc/php/php.ini
sudo cp $phpIni $phpIni.${dateFic}
echo "$phpIni saved as $phpIni.${dateFic}"
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $phpIni
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1G/g' $phpIni
sudo sed -i 's/post_max_size = 8M/post_max_size = 1G/g' $phpIni
#Ajout modules
sudo sed -i 's/;extension=posix\.so/extension=posix.so/' $phpIni
sudo sed -i 's/;extension=pdo_mysql\.so/extension=pdo_mysql.so/' $phpIni
sudo sed -i 's/;extension=zip\.so/extension=zip.so/' $phpIni
sudo sed -i 's/;extension=openssl\.so/extension=openssl.so/' $phpIni

#Installation de Jeedom 
sudo cp core/config/common.config.sample.php core/config/common.config.php
sudo sed -i -e "s/#PASSWORD#/${bdd_password}/g" core/config/common.config.php
sudo chown http: core/config/common.config.php
sudo php install/install.php mode=force

echo "/etc/php/php-fpm.conf modified, please restart php-fpm service"
echo "sample apache or nginx configs are in the directory /srv/http/jeedom/install/"

