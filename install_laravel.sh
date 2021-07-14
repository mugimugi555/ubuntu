#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_laravel.sh && bash install_laravel.sh ;

cd;
sudo echo;
sudo apt install -y apache2 php php-xml mariadb-server ;

#
php -r "copy ( 'https://getcomposer.org/installer', 'composer-setup.php' ) ;" ;
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer ;
composer -v ;

#
sudo mv /var/www/html/ /var/www/html_back ;
mkdir ~/html ;
sudo ln -s /home/$USER/html/ /var/www/html ;
echo "hi" > ~/html/index.html ;
xdg-open http://localhost/index.html &

#
composer global require laravel/installer ;
PATH="$PATH:$HOME/bin:$HOME/.config/composer/vendor/bin" ;
source .profile ;
laravel new testproject ;
sudo chown www-data:www-data -R testproject/storage testproject/bootstrap/cache ;
ln -s /home/$USER/testproject/public /var/www/html/testproject ;

xdg-open http://localhost/testproject &
