# Maintainer: saez0pub saez_pub hotmail com

pkgname=z-way
pkgver=1.7.2
pkgrel=1
pkgdesc="Z-Way communication stack"
arch=('armv6h')
url="http://razberry.z-wave.me"
license=('http://razberry.z-wave.me/docs/ZWAYEULA.pdf')
depends=('ffmpeg' 'php-ssh' 'ntp' 'unzip' 'mariadb' 'mariadb-clients'
         'libmariadbclient' 'nodejs' 'php' 'php-fpm' 'usb_modeswitch' 'python-pyserial'))
install=${pkgname}.install
source=("http://razberry.z-wave.me/z-way-server/z-way-server-RaspberryPiXTools-v1.7.2.tgz"
        "http://razberry.z-wave.me/webif_raspberry.tar.gz" "z-way-server.service" "z-way-server.logrotate")

md5sums=('SKIP')


package() {
  mkdir -p ${pkgdir}/srv/www/
  mkdir -p ${pkgdir}/srv/jeedom/var/
  unzip ${pkgdir}/jeedom.zip -d ${pkgdir}/srv/www/jeedom
}
