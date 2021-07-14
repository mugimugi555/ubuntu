#!/usr/bin/bash

cd;
sudo echo;
sudo apt install -y apache2 php php-xml mariadb-server composer ;

# or install compooser latest ver2.x manuary
# php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
# php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
# php composer-setup.php
# php -r "unlink('composer-setup.php');"
# sudo mv composer.phar /usr/local/bin/composer

#
sudo mv /var/www/html/ /var/www/html_back ;
mkdir ~/html ;
sudo ln -s /home/$USER/html/ /var/www/html ;
echo "hi" > ~/html/index.html ;
xdg-open http://localhost/index.html &

#
composer global require laravel/installer ; # composer ver.1 error :-)
composer global require laravel/installer ;
PATH="$PATH:$HOME/bin:$HOME/.config/composer/vendor/bin" ;
source .profile ;
laravel new testproject ;
sudo chown www-data:www-data -R testproject/storage testproject/bootstrap/cache ;
ln -s /home/$USER/testproject/public /var/www/html/testproject ;

xdg-open http://localhost/testproject &
