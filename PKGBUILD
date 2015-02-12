# Maintainer: saez0pub saez_pub hotmail com

pkgname=jeedom
pkgver=1.163.0
pkgrel=1
pkgdesc="Jeedom Home automation"
arch=('armv6h')
url="https://jeedom.fr"
license=('GPL')
depends=('ffmpeg' 'php-ssh' 'ntp' 'unzip' 'mariadb' 'mariadb-clients' 'cronie'
         'libmariadbclient' 'nodejs' 'php' 'php-fpm' 'usb_modeswitch' 'python-pyserial'
	 'miniupnpc')
install=${pkgname}.install
source=("https://market.jeedom.fr/jeedom/stable/jeedom.zip" 
        'jeedom.cron' 'jeedom.service' 'jeedom.postinstall.sh')

md5sums=('SKIP'
         'fc2592a10c993654a1db4f40e85d6b1d'
         'a5da1ebf150c8fe7e440da46d84e542e'
         '060fb31788be2260d52c0c960efb6d70')


package() {
  mkdir -p ${pkgdir}/srv/http/
  unzip jeedom.zip -d ${pkgdir}/srv/http/jeedom
  mkdir -p ${pkgdir}/srv/http/jeedom/tmp
  mkdir -p ${pkgdir}/etc/cron.d
  chmod  775 -R ${pkgdir}/srv/http/jeedom
  chown -R http: ${pkgdir}/srv/http/jeedom
  sed -i 's:^:  :g' ${pkgdir}/srv/http/jeedom/install/nginx_*
  sed -i 's:^  }:  }\n}:g' ${pkgdir}/srv/http/jeedom/install/nginx_*
  sed -i 's:^  server {:#user html;\nworker_processes  1;\n#error_log  logs/error.log;\n#error_log  logs/error.log  notice;\n#error_log  logs/error.log  info;\n#pid      logs/nginx.pid;\nevents {\n  worker_connections  1024;\n}\nhttp{\n  include       mime.types;\n  default_type  application/octet-stream;\n  sendfile        on;\n  server {:g' ${pkgdir}/srv/http/jeedom/install/nginx_*
  sed -i 's:/usr/share/nginx/www:/srv/http:g' ${pkgdir}/srv/http/jeedom/install/nginx_*
  sed -i 's:/var/www:/srv/http:g' ${pkgdir}/srv/http/jeedom/install/apache_default
  sed -i 's/\r//' ${pkgdir}/srv/http/jeedom/install/nginx_* ${pkgdir}/srv/http/jeedom/install/apache_default
  #Debian touch
  find ${pkgdir}/srv/http/jeedom/install/ ${pkgdir}/srv/http/jeedom/core/class/ -type f -exec sed -i 's:sites-available/jeedom_dynamic_rule:jeedom_dynamic_rule:g' {} \;
  install -D -m644 ${srcdir}/jeedom.cron ${pkgdir}/etc/cron.d/
  install -D -m644 ${srcdir}/jeedom.service ${pkgdir}/usr/lib/systemd/system/jeedom.service
  cp ${srcdir}/jeedom.postinstall.sh ${pkgdir}/srv/http/jeedom/install/
}
