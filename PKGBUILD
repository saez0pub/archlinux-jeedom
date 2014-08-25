# Maintainer: saez0pub saez_pub hotmail com

pkgname=jeedom
pkgver=1.94.0
pkgrel=1
pkgdesc="Jeedom Home automation"
arch=('armv6h')
url="https://jeedom.fr"
license=('GPL')
depends=('ffmpeg' 'php-ssh' 'ntp' 'unzip' 'mariadb' 'mariadb-clients'
         'libmariadbclient' 'nodejs' 'php' 'php-fpm' 'usb_modeswitch' 'python-pyserial')
#install=${pkgname}.install
source=("https://market.jeedom.fr/jeedom/stable/jeedom.zip" 
        'jeedom.cron')

md5sums=('SKIP'
         '2c44e18a6281eef773e61a75ef4aadb4')


package() {
  mkdir -p ${pkgdir}/srv/http/
  unzip jeedom.zip -d ${pkgdir}/srv/http/jeedom
}
