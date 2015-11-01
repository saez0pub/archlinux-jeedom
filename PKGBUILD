# Maintainer: saez0pub saez_pub hotmail com

pkgname=jeedom
pkgver=1.212.0
pkgrel=4
pkgdesc="Jeedom Home automation"
arch=('any')
url="https://jeedom.fr"
license=('GPL')
depends=('ffmpeg' 'php-ssh' 'ntp' 'unzip' 'mariadb-clients' 'cronie'
         'libmariadbclient' 'nodejs' 'php' 'php-fpm' 'usb_modeswitch' 'python-pyserial'
	 'miniupnpc' 'npm' 'tinyxml' 'curl' 'php-ldap' 'nginx')
optdepends=('mariadb' 'openzwave')
install=${pkgname}.install
source=("https://market.jeedom.fr/jeedom/stable/jeedom.zip"
        'jeedom.cron' 'jeedom.service' 'jeedom.postinstall.sh'
        'consistency.patch')

md5sums=('SKIP'
         'b7f9673fd49ec0cb7e3dbefdd80ba59b'
         '0aaab0f0d5b81bfb60cd6da03ba57a0d'
         '7a2598e6ea58c9d0040efa82d0d86eeb'
         'edb43d8d6fafdd1d8a297cd8ce21b293')

pkgver() {
  cat $srcdir/core/config/version
}

package() {
  mkdir -p ${pkgdir}/usr/share/webapps/
  unzip -q jeedom.zip -d ${pkgdir}/usr/share/webapps/jeedom
  find ${pkgdir}/usr/share/webapps/ -type d -exec chmod +x {} \;
  mkdir -p ${pkgdir}/usr/share/webapps/jeedom/tmp
  mkdir -p ${pkgdir}/etc/nginx/
  touch ${pkgdir}/etc/nginx/default
  mkdir -p ${pkgdir}/etc/cron.d
  patch ${pkgdir}/usr/share/webapps/jeedom/install/consistency.php < consistency.patch
  chmod  644 -R ${pkgdir}/usr/share/webapps/jeedom
  chown -R http: ${pkgdir}/usr/share/webapps/jeedom
  sed -i 's:^:  :g' ${pkgdir}/usr/share/webapps/jeedom/install/nginx_*
  sed -i 's:^  }:  }\n}:g' ${pkgdir}/usr/share/webapps/jeedom/install/nginx_*
  sed -i 's:^  server {:#user html;\nworker_processes  1;\n#error_log  logs/error.log;\n#error_log  logs/error.log  notice;\n#error_log  logs/error.log  info;\n#pid      logs/nginx.pid;\nevents {\n  worker_connections  1024;\n}\nhttp{\n  include       mime.types;\n  default_type  application/octet-stream;\n  sendfile        on;\n  server {:g' ${pkgdir}/usr/share/webapps/jeedom/install/nginx_*
  sed -i 's:/usr/share/nginx/www:/usr/share/webapps:g' ${pkgdir}/usr/share/webapps/jeedom/install/nginx_*
  sed -i 's:/var/www:/usr/share/webapps:g' ${pkgdir}/usr/share/webapps/jeedom/install/apache_default
  sed -i 's/\r//' ${pkgdir}/usr/share/webapps/jeedom/install/nginx_* ${pkgdir}/usr/share/webapps/jeedom/install/apache_default
  #Debian touch
  find ${pkgdir}/usr/share/webapps/jeedom/install/ ${pkgdir}/usr/share/webapps/jeedom/core/class/ -type f -exec sed -i  -e 's:sites-available/::g' -e "s:'/proc/' . $this->getPID() . '/cmdline':/proc/self/cmdline:g"  {} \;
  install -D -m644 ${srcdir}/jeedom.cron ${pkgdir}/etc/cron.d/
  install -D -m644 ${srcdir}/jeedom.service ${pkgdir}/usr/lib/systemd/system/jeedom.service
  cp ${srcdir}/jeedom.postinstall.sh ${pkgdir}/usr/share/webapps/jeedom/install/
  chmod +x ${pkgdir}/usr/share/webapps/jeedom/install/jeedom.postinstall.sh
  touch ${pkgdir}/etc/nginx/jeedom_dynamic_rule
}
