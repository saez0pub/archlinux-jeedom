#!/bin/bash

## Adapted from https://github.com/saez0pub/archlinux-jeedom.

nginxString="nginx"
apacheString="apache"

function usage {
    cat <<EOF

Usage: `basename $0` [-web WEBSERVER] [-jeedom DIR]
where WEBSERVER is "$nginxString" or "$apacheString".
Default is "$nginxString".
Use the "-jeedom" flag to specify the path to jeedom.
If none is provided, jeedom will be retrieved for you.

Retrieves the dependencies for Jeedom and installs it.
Official website:
> https://jeedom.fr/index-en.php

EOF
}	    


function error {
    printf "\n\033[31mError\033[0m: $1\n"
    usage
    exit 1
}

## Option things.

while :
do
    case $1 in
	-h | --help)
	    usage
	    exit 0
	    ;;
	-web)
	    if [ ! "$2" ]; then
		error "-web flag active but no webserver specified."
	    elif [[ "$2" = "$nginxString" || "$2" = "$apacheString" ]]; then
		webserver="$2"
	    else
		error "unexpected webserver [$2]."
	    fi
	    shift 2
	    ;;
	-jeedom)
	    if [ ! "$2" ]; then
		error "-jeedom flag active but no directory specified."
	    elif [ -d "$2" ]; then
		jeedomDir="$2"
	    else
		error "directory [$2] does not exist."
	    fi
	    shift 2
	    ;;
	*)
	    if [ "$1" = "" ]; then
		shift
	    else
		error "unexpected argument [$1]."
	    fi
	    shift
	    break
	    ;;
    esac
done

if [ "$webserver" = "" ]; then
    echo
    echo "Using default webserver \"$nginxString\"."
    webserver="$nginxString"
    echo
else
    echo
fi



function userConfirm {

    while true; do

	printf "\033[31m/!\\ \033[0mDefault configuration for $webserver will be overwritten. \033[31m/!\\ \033[0m\n"
	echo "Are you sure you want to install Jeedom? (yes/no):"

	printf "> "
	read answer < /dev/tty
	case $answer in
	    yes)
		break
		;;
	    no)
		echo "Cancelling installation."
		exit 0
		;;
	esac
	echo "Unexpected answer \"$answer\"."
    done
}

function echoEval {
    echo "> $@"
    # eval "$@"
    if [ "$?" -ne "0" ]; then
	error "Last command did not return successfully."
    fi
}


## Starting to do things.


userConfirm

echo
echo "********************************************************"
echo "*                Retrieving dependencies               *"
echo "********************************************************"
echo

echoEval "sudo apt-get update"

if [ "${webserver}" = "nginx" ] ; then
    echoEval "sudo apt-get install -y nginx-common nginx-full"
elif [ "${webserver}" = "apache" ] ; then 
    echoEval "sudo apt-get install -y apache2 libapache2-mod-php5"
    echoEval "sudo apt-get install -y autoconf make subversion"
    echoEval "sudo svn checkout http://svn.apache.org/repos/asf/httpd/httpd/tags/2.2.22/ httpd-2.2.22"
    echoEval "sudo wget http://cafarelli.fr/gentoo/apache-2.2.24-wstunnel.patch"
    echoEval "sudo cd httpd-2.2.22"
    echoEval "sudo patch -p1 < ../apache-2.2.24-wstunnel.patch"
    echoEval "sudo svn co http://svn.apache.org/repos/asf/apr/apr/branches/1.4.x srclib/apr"
    echoEval "sudo svn co http://svn.apache.org/repos/asf/apr/apr-util/branches/1.3.x srclib/apr-util"
    echoEval "sudo ./buildconf"
    echoEval "sudo ./configure --enable-proxy=shared --enable-proxy_wstunnel=shared"
    echoEval "sudo make"
    echoEval "sudo cp modules/proxy/.libs/mod_proxy{_wstunnel,}.so /usr/lib/apache2/modules/"
    echoEval "sudo chmod 644 /usr/lib/apache2/modules/mod_proxy{_wstunnel,}.so"
    line="# Depends: proxy\nLoadModule proxy_wstunnel_module /usr/lib/apache2/modules/mod_proxy_wstunnel.so"
    echoEval "echo \"$line\" | sudo tee -a /etc/apache2/mods-available/proxy_wstunnel.load"
    echoEval "sudo a2enmod proxy_wstunnel"
    echoEval "sudo a2enmod proxy_http"
    echoEval "sudo a2enmod proxy"
    echoEval "sudo service apache2 restart"
fi

echoEval "sudo apt-get install -y ffmpeg"
echoEval "sudo apt-get install -y libssh2-php"
echoEval "sudo apt-get install -y ntp"
echoEval "sudo apt-get install -y unzip"
echoEval "sudo apt-get install -y mysql-client mysql-common mysql-server mysql-server-core-5.5"

function userPass {
    password1=""
    password2=""

    while true; do
	echo "Enter root password for MySql:"
	printf "> "
	read -s password1 < /dev/tty
	echo
	echo "Confirm root password for MySql:"
	printf "> "
	read -s password2 < /dev/tty
	echo
	if [ "$password1" = "$password2" ]; then
	    break
	else
	    echo "Password missmatch."
	fi
    done
}

userPass
mySqlPass="$password1"

echoEval "sudo apt-get install -y nodejs"
nodeJS=$?
echoEval "sudo apt-get install -y php5-common php5-fpm php5-cli php5-curl php5-json php5-mysql"
echoEval "sudo apt-get install -y usb-modeswitch python-serial"

echo
echo "********************************************************"
echo "*    Creating directories and setting permissions      *"
echo "********************************************************"
echo

if [ "${webserver}" = "nginx" ] ; then 
    echoEval "sudo mkdir -p /usr/share/nginx/www"
    echoEval "cd /usr/share/nginx/www"
    echoEval "chown www-data:www-data -R /usr/share/nginx/www"
elif [ "${webserver}" = "apache" ] ; then 
    echoEval "sudo mkdir -p /var/www"
    echoEval "cd /var/www"
    echoEval "chown www-data:www-data -R /var/www"
fi

if [ "${webserver}" = "nginx" ] ; then 
    echoEval "sudo mkdir /usr/share/nginx/www/jeedom/tmp"
    echoEval "sudo chmod 775 -R /usr/share/nginx/www"
    echoEval "sudo chown -R www-data:www-data /usr/share/nginx/www"
elif [ "${webserver}" = "apache" ] ; then 
    echoEval "sudo mkdir /var/www/jeedom/tmp"
    echoEval "sudo chmod 775 -R /var/www"
    echoEval "sudo chown -R www-data:www-data /var/www"
fi

echo
echo "********************************************************"
echo "*                 Copying Jeedom files                 *"
echo "********************************************************"
echo

if [ "$jeedomDir" = "" ]; then
    ## Retrieving jeedom.
    if [ -d "jeedom" ] ; then
	echoEval "rm -rf jeedom"
    fi
    echoEval "wget -O jeedom.zip https://market.jeedom.fr/jeedom/stable/jeedom.zip"

    if [  $? -ne 0 ] ; then
	echoEval "wget -O jeedom.zip https://market.jeedom.fr/jeedom/stable/jeedom.zip"
	if [  $? -ne 0 ] ; then
            error "failed to download file."
	fi
    fi

    echoEval "unzip jeedom.zip -d jeedom"

    echoEval "rm -rf jeedom.zip"
    echoEval "cd jeedom"
else
    ## Cd'ing to jeedom directory.
    echoEval "cd $jeedomDir"
fi

if [ ${nodeJS} -ne 0 ] ; then
    x86=$(uname -a | grep x86_64 | wc -l)
    if [ ${x86} -ne 0 ] ; then
	echo
        echo "********************************************************"
        echo "*           Installing nodeJS manualy for x86          *"
        echo "********************************************************"
	echo
        echoEval "sudo deb http://http.debian.net/debian wheezy-backports main"
        echoEval "sudo apt-get install -y nodejs"
    else
	echo
        echo "********************************************************"
        echo "*           Installing nodeJS manualy for ARM          *"
        echo "********************************************************"
	echo
        echoEval "wget https://jeedom.fr/ressources/nodejs/node-v0.10.21-cubie.tar.xz"
        echoEval "sudo tar xJvf node-v0.10.21-cubie.tar.xz -C /usr/local --strip-components 1"
        if [ ! -f '/usr/bin/nodejs' ] && [ -f '/usr/local/bin/node' ]; then
            echoEval "sudo ln -s /usr/local/bin/node /usr/bin/nodejs"
        fi
        echoEval "sudo rm -rf node-v0.10.21-cubie.tar.xz"
    fi
elif [ $( cat /etc/os-release | grep raspbian | wc -l) -gt 0 ] ; then
    echo
    echo "********************************************************"
    echo "*        Installing nodeJS manualy for Raspberry       *"
    echo "********************************************************"
    echo
    echoEval "wget https://jeedom.fr/ressources/nodejs/node-raspberry.bin"
    echoEval "sudo rm -rf /usr/local/bin/node"
    echoEval "sudo rm -rf /usr/bin/nodejs"
    echoEval "sudo mv node-raspberry.bin /usr/local/bin/node"
    echoEval "sudo ln -s /usr/local/bin/node /usr/bin/nodejs"
    echoEval "sudo chmod +x /usr/local/bin/node"
fi

echo
echo "********************************************************"
echo "*                 Configuring database                 *"
echo "********************************************************"
echo

bdd_password=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 15)
echo "DROP USER 'jeedom'@'localhost'" | mysql -uroot -p${MySQL_root}
echo "CREATE USER 'jeedom'@'localhost' IDENTIFIED BY '${bdd_password}';" | mysql -uroot -p${MySQL_root}
echo "DROP DATABASE IF EXISTS jeedom;" | mysql -uroot -p${MySQL_root}
echo "CREATE DATABASE jeedom;" | mysql -uroot -p${MySQL_root}
echo "GRANT ALL PRIVILEGES ON jeedom.* TO 'jeedom'@'localhost';" | mysql -uroot -p${MySQL_root}

echo
echo "********************************************************"
echo "*                  Installing Jeedom                   *"
echo "********************************************************"
echo

echoEval "sudo cp core/config/common.config.sample.php core/config/common.config.php"
echoEval "sudo sed -i -e \"s/#PASSWORD#/${bdd_password}/g\" core/config/common.config.php "
echoEval "sudo chown www-data:www-data core/config/common.config.php"
echoEval "sudo php install/install.php mode=force"

echo
echo "********************************************************"
echo "*                   Setting up cron                    *"
echo "********************************************************"
echo

if [ "${webserver}" = "nginx" ] ; then 
    croncmd="su --shell=/bin/bash - www-data -c '/usr/bin/php /usr/share/nginx/www/jeedom/core/php/jeeCron.php' >> /dev/null"
elif [ "${webserver}" = "apache" ] ; then
    croncmd="su --shell=/bin/bash - www-data -c '/usr/bin/php /var/www/jeedom/core/php/jeeCron.php' >> /dev/null"
fi

cronjob="* * * * * $croncmd"

echoEval "( crontab -l | grep -v \"$croncmd\" ; echo \"$cronjob\" ) | crontab -"


if [ "${webserver}" = "nginx" ] ; then
    echo
    echo "********************************************************"
    echo "*                  Configuring NGINX                   *"
    echo "********************************************************"
    echo

    if [ -f '/etc/init.d/apache2' ]; then
        echoEval "sudo service apache2 stop"
        echoEval "sudo update-rc.d apache2 remove"
    fi
    if [ -f '/etc/init.d/apache' ]; then
        echoEval "sudo service apache stop"
        echoEval "sudo update-rc.d apache remove"
    fi

    echoEval "sudo service nginx stop"
    if [ -f '/etc/nginx/sites-available/defaults' ]; then
        echoEval "sudo rm /etc/nginx/sites-available/default"
    fi
    echoEval "sudo cp install/nginx_default /etc/nginx/sites-available/default"
    if [ ! -f '/etc/nginx/sites-enabled/default' ]; then
        echoEval "sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default"
    fi
    echoEval "sudo service nginx restart"
    echoEval "sudo adduser www-data dialout"
    echoEval "sudo adduser www-data gpio"
    echoEval "sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php5/fpm/php.ini"
    echoEval "sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1G/g' /etc/php5/fpm/php.ini"
    echoEval "sudo sed -i 's/post_max_size = 8M/post_max_size = 1G/g' /etc/php5/fpm/php.ini"
    echoEval "sudo service php5-fpm restart"
    echoEval "sudo /etc/init.d/php5-fpm restart"

elif [ "${webserver}" = "apache" ] ; then
    echo
    echo "********************************************************"
    echo "*                  Configuring APACHE                  *"
    echo "********************************************************"
    echo
    
    echoEval "sudo cp install/apache_default /etc/apache2/sites-available/000-default.conf"
    if [ ! -f '/etc/apache2/sites-enabled/000-default.conf' ]; then
        echoEval "sudo a2ensite 000-default"
    fi
    echoEval "sudo service apache2 restart"
    echoEval "sudo adduser www-data dialout"
    echoEval "sudo adduser www-data gpio"
    echoEval "sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php5/fpm/php.ini"
    echoEval "sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1G/g' /etc/php5/fpm/php.ini"
    echoEval "sudo sed -i 's/post_max_size = 8M/post_max_size = 1G/g' /etc/php5/fpm/php.ini"
    echoEval "sudo service php5-fpm restart"
    echoEval "sudo /etc/init.d/php5-fpm restart"
fi

echo
echo "********************************************************"
echo "*                   Setting up nodeJS                  *"
echo "********************************************************"
echo

echoEval "sudo cp jeedom /etc/init.d/"
echoEval "sudo chmod +x /etc/init.d/jeedom"
echoEval "sudo update-rc.d jeedom defaults"

if [ "${webserver}" = "apache" ] ; then 
    echoEval "sudo sed -i 's%PATH_TO_JEEDOM=\"/usr/share/nginx/www/jeedom\"%PATH_TO_JEEDOM=\"/var/www/jeedom\"%g' /etc/init.d/jeedom"
fi

echo
echo "********************************************************"
echo "*                 Startng service nodeJS               *"
echo "********************************************************"
echo

echoEval "sudo service jeedom start"

echo
echo "********************************************************"
echo "*              Post-installation setup                 *"
echo "********************************************************"
echo

echoEval "sudo cp install/motd /etc"
echoEval "sudo chown root:root /etc/motd"
echoEval "sudo chmod 644 /etc/motd"

echo
echo "********************************************************"
echo "*                      All done                        *"
echo "********************************************************"
echo

IP=`dig +short myip.opendns.com @resolver1.opendns.com`
echo "You can connect to jeedom by going to $IP/jeedom."
echo "Default credentials:"
echo "> login: admin"
echo "> pass:  admin"
echo
echo "Remember to change them as soon as possible."
echo
