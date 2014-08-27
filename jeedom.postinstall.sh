#!/bin/bash


echo "Quel mot de passe venez vous de taper (mot de passe root de la MySql) ?"
while true
do
        read MySQL_root < /dev/tty
        echo "Confirmez vous que le mot de passe est : "${MySQL_root}
        while true
        do
            echo -n "oui/non: "
            read ANSWER < /dev/tty
            case $ANSWER in
                        oui)
                                break
                                ;;
                        non)
                                break
                                ;;
            esac
            echo "Répondez oui ou non"
        done
        if [ "${ANSWER}" = "oui" ]; then
            break
        fi
done

cd /srv/http/jeedom
#Configuration de la base de données
bdd_password=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 15)
echo "DROP USER 'jeedom'@'localhost'" > /tmp/mysql_install_$$.sql
echo "CREATE USER 'jeedom'@'localhost' IDENTIFIED BY '${bdd_password}';" >> /tmp/mysql_install_$$.sql
echo "DROP DATABASE IF EXISTS jeedom;" >> /tmp/mysql_install_$$.sql
echo "CREATE DATABASE jeedom;" >> /tmp/mysql_install_$$.sql
echo "GRANT ALL PRIVILEGES ON jeedom.* TO 'jeedom'@'localhost';" >> /tmp/mysql_install_$$.sql

mysql -u root -p${MySQL_root} < /tmp/mysql_install_$$.sql

rm -f /tmp/mysql_install_$$.sql

#Installation de Jeedom 
sudo cp core/config/common.config.sample.php core/config/common.config.php
sudo sed -i -e "s/#PASSWORD#/${bdd_password}/g" core/config/common.config.php
sudo chown http: core/config/common.config.php
sudo php install/install.php mode=force

dateFic=$(date +%s)
sudo cp /etc/php5/fpm/php.ini /etc/php5/fpm/php.ini.${dateFic}
echo "/etc/php/php-fpm.conf saved as /etc/php/php-fpm.conf.${dateFic}"
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/php-fpm.conf
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1G/g' /etc/php/php-fpm.conf
sudo sed -i 's/post_max_size = 8M/post_max_size = 1G/g' /etc/php/php-fpm.conf

echo "/etc/php/php-fpm.conf modified, please restart php-fpm service"
echo "sample apache or nginx configs are in the directory /srv/http/jeedom/install/"

