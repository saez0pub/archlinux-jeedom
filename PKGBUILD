# Maintainer: saez0pub saez_pub hotmail com

pkgname=jeedom
pkgver=1.94.0
pkgrel=1
pkgdesc="Jeedom Home automation"
arch=('armv6h')
url="https://jeedom.fr"
license=('GPL')
depends=('ffmpeg' 'php-ssh' 'ntp' 'unzip' 'mariadb' 'mariadb-clients' 'cronie'
         'libmariadbclient' 'nodejs' 'php' 'php-fpm' 'usb_modeswitch' 'python-pyserial')
#install=${pkgname}.install
source=("https://market.jeedom.fr/jeedom/stable/jeedom.zip" 
        'jeedom.cron' 'jeedom.service' 'jeedom.postinstall.sh')

md5sums=('SKIP'
         '2c44e18a6281eef773e61a75ef4aadb4'
         'a5da1ebf150c8fe7e440da46d84e542e'
         'b628ff941749c69b65233294592461d9')


package() {
  mkdir -p ${pkgdir}/srv/http/
  unzip jeedom.zip -d ${pkgdir}/srv/http/jeedom
  mkdir -p ${pkgdir}/srv/http/jeedom/tmp
  mkdir -p ${pkgdir}/etc/cron.d
  chmod  775 -R ${pkgdir}/srv/http/jeedom
  chown -R http: ${pkgdir}/srv/http/jeedom
  sed -i 's:/usr/share/nginx/www/:/srv/http/:g' ${pkgdir}/srv/http/jeedom/install/nginx_default
  sed -i 's:/var/www/:/srv/http/:g' ${pkgdir}/srv/http/jeedom/install/apache_default
  install -D -m644 ${srcdir}/jeedom.cron ${pkgdir}/etc/cron.d/
  install -D -m644 ${srcdir}/jeedom.service ${pkgdir}/usr/lib/systemd/system/jeedom.service
  cp ${srcdir}/jeedom.postinstall.sh ${pkgdir}/srv/http/jeedom/install/
}
