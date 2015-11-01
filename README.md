archlinux-jeedom Too much breaking changes, debian dependencies and security questions to be maintained
================

Jeedom on archlinux

## Installation ##

```
yaourt -Sy php-ssh
```
Edit PKGBUILD of php-ssh and replace arch by 'any'
```
makepkg -s
```

*Choose your webserver :
sudo pacman -Sy nginx or sudo pacman -Sy httpd

## Post installation ##
```
sudo systemctl enable mysqld
sudo systemctl enable cronie
sudo systemctl enable jeedom
sudo systemctl enable php-fpm
sudo systemctl enable nginx OR sudo systemctl enable httpd
sudo systemctl start mysqld
sudo systemctl start cronie
/usr/share/webapps/jeedom/install/jeedom.postinstall.sh
sudo systemctl start php-fpm
```
*Choose your webserver conf in /usr/share/webapps/jeedom/install/
**For nginx, don't forget cp /usr/share/webapps/jeedom/install/nginx_jeedom_dynamic_rules /etc/nginx/jeedom_dynamic_rule && chmod 777 /etc/nginx/jeedom_dynamic_rule
```
sudo systemctl start nginx OR sudo systemctl start httpd
sudo systemctl start z-way
sudo systemctl start jeedom
```
