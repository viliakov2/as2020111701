#!/bin/bash

set -x

export HOME=/root
export COMPOSER_HOME=/root/.config/composer

COMPOSER_USERNAME=$(aws ssm get-parameter --region ${aws_region} --name ${composer_username_ssm_name} --with-decryption --output text --query "Parameter.Value")
COMPOSER_PASSWORD=$(aws ssm get-parameter --region ${aws_region} --name ${composer_password_ssm_name} --with-decryption --output text --query "Parameter.Value")
CLOUDFROUNT_URL=$(aws ssm get-parameter --region ${aws_region} --name ${cloudfrount_url_ssm_name} --with-decryption --output text --query "Parameter.Value")
EFS_MOUNT_TARGET=$(aws ssm get-parameter --region ${aws_region} --name ${efs_mount_target_ssm_name} --with-decryption --output text --query "Parameter.Value")
MAGENTO_LB_ADDRESS=$(aws ssm get-parameter --region ${aws_region} --name ${magento_lb_address_ssm_name} --with-decryption --output text --query "Parameter.Value")
MAGENTO_ADMIN_USER=$(aws ssm get-parameter --region ${aws_region} --name ${magento_admin_user_ssm_name} --with-decryption --output text --query "Parameter.Value")
MAGENTO_ADMIN_PASSWORD=$(aws ssm get-parameter --region ${aws_region} --name ${magento_admin_password_ssm_name} --with-decryption --output text --query "Parameter.Value")
MAGENTO_DB_HOST=$(aws ssm get-parameter --region ${aws_region} --name ${magento_db_host_ssm_name} --with-decryption --output text --query "Parameter.Value")
MAGENTO_DB_NAME=$(aws ssm get-parameter --region ${aws_region} --name ${magento_db_name_ssm_name} --with-decryption --output text --query "Parameter.Value")
MAGENTO_DB_USERNAME=$(aws ssm get-parameter --region ${aws_region} --name ${magento_db_username_ssm_name} --with-decryption --output text --query "Parameter.Value")
MAGENTO_DB_PASSWORD=$(aws ssm get-parameter --region ${aws_region} --name ${magento_db_password_ssm_name} --with-decryption --output text --query "Parameter.Value")
MAGENTO_REDIS_HOST=$(aws ssm get-parameter --region ${aws_region} --name ${magento_redis_host_ssm_name} --with-decryption --output text --query "Parameter.Value")



# The SSM paramater is used to syncronise installation across multiple nodes.
# It can run successfully only once and the first node to run it will be source of the generated configuration file
aws ssm put-parameter --region ${aws_region} --name "/magento/installation-progress" --type String --value "INPROGRESS"
if [ $? -eq 0 ]; then
    MASTER="true"
else
# Wait till installation complete
    STATUS=$(aws ssm get-parameter --region ${aws_region} --name "/magento/installation-progress" --query "Parameter.Value")
    while  [[ ! "$STATUS" =~ "COMPLETED" ]]
    do
        STATUS=$(aws ssm get-parameter --region ${aws_region} --name "/magento/installation-progress" --query "Parameter.Value")
        sleep 30
    done
fi

# install magento
yum update -y

# Ensure php 7.4 for installation
amazon-linux-extras enable php7.4
# Install Magento prerequisites
yum install -y php php-pdo  php-mysqlnd php-opcache php-xml php-gd php-devel php-intl php-mbstring php-bcmath php-json php-soap  php-fpm  mariadb
amazon-linux-extras install -y nginx1

sed -i 's#memory_limit =.*$#memory_limit = 2G#g' /etc/php.ini
sed -i 's#max_execution_time =.*$#max_execution_time = 1800#g' /etc/php.ini
sed -i 's#zlib.output_compression =.*$#zlib.output_compression = On#g' /etc/php.ini
sed -i 's#group = apache#group = nginx#g' /etc/php-fpm.d/www.conf
systemctl enable php-fpm
systemctl start php-fpm


# Getting Composer
curl -L https://getcomposer.org/download/1.10.17/composer.phar -o /usr/local/bin/composer
chmod a+x /usr/local/bin/composer

mkdir -p /root/.config/composer/
cat <<EOF >  /root/.config/composer/auth.json
{
    "bitbucket-oauth": {},
    "github-oauth": {},
    "gitlab-oauth": {},
    "gitlab-token": {},
    "http-basic": {
       "repo.magento.com": {
          "username": "$COMPOSER_USERNAME",
          "password": "$COMPOSER_PASSWORD"
       }
    },
    "bearer": {}
}
EOF

# Installing Magento
cd /var/www/

/usr/local/bin/composer create-project -n --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.1 magento

mv /var/www/magento/pub /var/www/magento/pub_tmp
mkdir /var/www/magento/pub
sed -i '\/var\/www\/magento\/pub/d' /etc/fstab
echo "$EFS_MOUNT_TARGET:/ /var/www/magento/pub nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" > /etc/fstab
mount /var/www/magento/pub
rsync -a /var/www/magento/pub_tmp/ /var/www/magento/pub/
rm -Rf /var/www/magento/pub_tmp


cd /var/www/magento
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} \;
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} \;
chown -R :nginx .

bin/magento setup:install \
--disable-modules 'Magento_Elasticsearch,Magento_InventoryElasticsearch,Magento_Elasticsearch6,Magento_Elasticsearch7' \
--base-url=$MAGENTO_LB_ADDRESS \
--db-host=$MAGENTO_DB_HOST \
--db-name=$MAGENTO_DB_NAME \
--db-user=$MAGENTO_DB_USERNAME \
--db-password=$MAGENTO_DB_PASSWORD \
--admin-firstname=admin \
--admin-lastname=admin \
--admin-email=admin@admin.com \
--admin-user=$MAGENTO_ADMIN_USER \
--admin-password=$MAGENTO_ADMIN_PASSWORD \
--session-save=redis \
--session-save-redis-host=$MAGENTO_REDIS_HOST \
--session-save-redis-db=2 \
--session-save-redis-port=6379 \
--cache-backend=redis \
--cache-backend-redis-server=$MAGENTO_REDIS_HOST \
--cache-backend-redis-db=0 \
--cache-backend-redis-port=6379 \
--page-cache=redis \
--page-cache-redis-server=$MAGENTO_REDIS_HOST \
--page-cache-redis-db=1 \
--page-cache-redis-port=6379 \
--language=en_US \
--currency=USD \
--timezone=UTC \
--use-rewrites=0

bin/magento config:set web/unsecure/base_media_url $CLOUDFROUNT_URL/media/
bin/magento config:set web/unsecure/base_static_url $CLOUDFROUNT_URL/static/


cat <<EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    upstream fastcgi_backend {
    server  unix:/var/run/php-fpm/www.sock;
    }
    server {
    listen 80;
    set \$MAGE_ROOT /var/www/magento;
    include /var/www/magento/nginx.conf.sample;
    }
}
EOF



if [ "$MASTER" == "true" ]; then
    ENVCONF=$(cat app/etc/env.php)
    aws ssm put-parameter --region ${aws_region} --name "/magento/env-php" --type SecureString --value file:///var/www/magento/app/etc/env.php
    aws ssm put-parameter --region ${aws_region} --name "/magento/installation-progress" --overwrite --type String --value "COMPLETED"
else
    ENVPHP=$(aws ssm get-parameter --region ${aws_region} --name "/magento/env-php" --with-decryption --output text --query "Parameter.Value")
    echo $ENVPHP > app/etc/env.php
fi

systemctl enable nginx
systemctl start nginx
