#!/bin/bash

# Variables
# Mot de passe pour l'utilisateur root de MySQL
MYSQL_ROOT_PASSWORD="StrongRootPassword123"

# Nom de la base de données pour WordPress
WP_DB_NAME="wordpress_db"

# Nom de l'utilisateur MySQL pour WordPress
WP_DB_USER="wordpress_user"

# Mot de passe pour l'utilisateur WordPress dans MySQL
WP_DB_PASSWORD="SecureWpPassword456"

# Mise à jour du système
echo "Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

# Installation des dépendances
echo "Installation des paquets nécessaires..."
sudo apt install apache2 \
            mysql-server \
            php \
            php-mysql \
            php-curl \
            php-gd \
            php-mbstring \
            php-xml \
            php-xmlrpc \
            php-soap \
            php-intl \
            php-zip \
            wget \
            unzip -y

# Configuration de PHP pour WordPress
echo "Configuration de PHP..."
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php/*/apache2/php.ini
sudo sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php/*/apache2/php.ini
sudo sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/*/apache2/php.ini

# Démarrage et activation des services
echo "Démarrage des services..."
sudo systemctl start apache2
sudo systemctl start mysql
sudo systemctl enable apache2
sudo systemctl enable mysql

# Configuration de MySQL
echo "Configuration de MySQL..."
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"
sudo mysql -e "CREATE DATABASE $WP_DB_NAME;"
sudo mysql -e "CREATE USER '$WP_DB_USER'@'localhost' IDENTIFIED BY '$WP_DB_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO '$WP_DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Téléchargement et installation de WordPress
echo "Installation de WordPress..."
cd /tmp
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv wordpress /var/www/html/
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Création du fichier de configuration WordPress
sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo sed -i "s/database_name_here/$WP_DB_NAME/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/$WP_DB_USER/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/$WP_DB_PASSWORD/" /var/www/html/wordpress/wp-config.php

# Génération des clés de sécurité
KEYS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
sudo sed -i "/define( 'AUTH_KEY'/,/define( 'NONCE_SALT'/c\\$KEYS" /var/www/html/wordpress/wp-config.php

# Configuration d'Apache
echo "Configuration d'Apache..."
sudo tee /etc/apache2/sites-available/wordpress.conf << EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html/wordpress

    <Directory /var/www/html/wordpress>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/wordpress_error.log
    CustomLog \${APACHE_LOG_DIR}/wordpress_access.log combined
</VirtualHost>
EOF

# Activation du site et des modules nécessaires
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

echo "Installation terminée !"
echo "Accédez à votre serveur en utilisant son nom de domaine ou son adresse IP publique pour terminer la configuration de WordPress."
echo "Informations de base de données à utiliser :"
echo "Nom de la base de données : $WP_DB_NAME"
echo "Utilisateur : $WP_DB_USER"
echo "Mot de passe : $WP_DB_PASSWORD"
