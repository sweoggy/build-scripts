#!/bin/bash

apt install m4 libreadline-dev libenchant-dev libxml2-dev libpcre3-dev libbz2-dev libcurl4-openssl-dev libjpeg-dev libpng12-0 libxpm-dev libfreetype6-dev libmysqlclient-dev libgd-dev libgmp-dev libsasl2-dev libmhash-dev unixodbc-dev freetds-dev libpspell-dev libsnmp-dev libtidy-dev libxslt1-dev libmcrypt-dev

wget http://launchpadlibrarian.net/140087283/libbison-dev_2.7.1.dfsg-1_amd64.deb
wget http://launchpadlibrarian.net/140087282/bison_2.7.1.dfsg-1_amd64.deb
dpkg -i libbison-dev_2.7.1.dfsg-1_amd64.deb
dpkg -i bison_2.7.1.dfsg-1_amd64.deb

git clone https://github.com/php/php-src.git -b PHP-7.1 --depth=1
cd php-src/ext
git clone https://github.com/krakjoe/pthreads -b master pthreads
cd pthreads
git reset --hard 527286336ffcf5fffb285f1bfeb100bb8bf5ec32
cd ../../

printf "\n\nBuilding and installing PHP\n\n"

./buildconf --force

#--with-bz2
./configure --prefix=/opt/php-zts --with-zlib --enable-zip --disable-cgi \
	--enable-soap --enable-intl --with-mcrypt --with-openssl --with-readline --with-curl \
	--enable-ftp --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
	--enable-sockets --enable-pcntl --with-pspell --with-enchant --with-gettext \
	--with-gd --enable-exif --with-jpeg-dir --with-png-dir --with-freetype-dir --with-xsl \
	--enable-bcmath --enable-mbstring --enable-calendar --enable-simplexml --enable-json \
	--enable-hash --enable-session --enable-xml --enable-wddx --enable-opcache \
	--with-pcre-regex --with-config-file-path=/etc/php/7.1/cli \
	--with-config-file-scan-dir=/etc/php/7.1/cli/conf.d --enable-cli --enable-maintainer-zts \
	--with-tsrm-pthreads
#--enable-debug

make && make install

ln -s -f /opt/php-zts/bin/php /usr/bin/php-zts
ln -s -f /opt/php-zts/bin/phpize /usr/bin/phpize-zts
ln -s -f /opt/php-zts/bin/php-config /usr/bin/php-config-zts
ln -s -f /opt/php-zts/bin/php-cgi /usr/bin/php-cgi-zts
ln -s -f /opt/php-zts/bin/phpdbg /usr/bin/phpdbg-zts
ln -s -f /opt/php-zts/bin/pear /usr/bin/pear-zts
ln -s -f /opt/php-zts/bin/pecl /usr/bin/pecl-zts


printf "\n\nBuilding and installing pthreads\n\n"

cd ext/pthreads*
phpize-zts

./configure --prefix=/opt/php-zts --with-libdir=/lib/x86_64-linux-gnu --enable-pthreads=shared --with-php-config=php-config-zts

make && make install


printf "\n\nInstalling various extensions\n\n"

cd ../../

pecl-zts channel-update pear.php.net

pecl-zts install xdebug
pecl-zts install apcu
pecl-zts install apcu_bc-beta


printf "\n\nEnabling pthreads\n\n"

bash -c 'echo "extension=pthreads.so" > /etc/php/7.1/mods-available/pthreads.ini'
ln -s /etc/php/7.1/mods-available/pthreads.ini /etc/php/7.1/cli/conf.d/pthreads.ini
