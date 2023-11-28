Git clone the project

```
git clone https://github.com/hc0503/laravel7-qrcode-campaign.git
cd laravel7-qrcode-campaign
```

Environment file setup

```
cp .env.example .env

nano .env

Update database variables for mysql 
For local run change db connection to localhost from 127.0.0.1
```

Create the Dockerfile in the same directory as all other files and folder

```
# Use the official Ubuntu 20.04 base image
FROM ubuntu:22.04

# Set non-interactive mode during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary packages
RUN apt-get update && \
    apt-get install -y git php php-gd php-xml php-mysql composer nodejs npm mysql-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the MySQL root password
RUN echo "mysql-server mysql-server/root_password password password" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password password" | debconf-set-selections

RUN service mysql stop
RUN usermod -d /var/lib/mysql/ mysql

# Create a new database named 'laravel' and run migrations
RUN service mysql start && \
    mysql -u root -ppassword -e "CREATE DATABASE laravel;"

# Set the working directory to the Laravel project directory
WORKDIR /var/www/html

# Copy your Laravel project files into the container
COPY . .

# Install PHP dependencies using Composer
RUN composer install

# Generate Laravel application key
RUN php artisan key:generate

# Install Node.js dependencies
RUN npm install

# Expose port 8000 for the Laravel development server
EXPOSE 8000

# Start the Laravel development server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]

```

Build Process

```
sudo docker build . -t qrgen
sudo docker run -d --restart unless-stopped --name qrapp -p 8000:8000 qrgen
sudo docker exec -it qrapp /bin/bash
```

Once in docker container, Initialize the mysql instance and run the migration:

```
Step 1: Start the mysql service
service mysql start

Step 2: Run mysql
mysql

Step 3: Update the password
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
quit

Step 4: Run the migration
php artisan migrate --seed

Step 5: Exit the interactive mode from container
exit
```

The application can be accessed at http://0.0.0.0:8000/login

➢ Once above server is setup.
➢ Need to Setup:
https://ipstack.com/?utm_source=apilayermarketplace&utm_medium=featured
➢ Get a login, and get the API key.
➢ Replace the API key in > QRCodeGenerator.php
➢ Now, generate a new QR code:

Below doesn't work yet but is a better approach for future.



```bash
# Use the official MySQL image as the base image
FROM mysql:latest

# Set the environment variables for MySQL root user password
ENV MYSQL_ROOT_PASSWORD=qr-apex-404
ENV MYSQL_DATABASE=laravel

#docker build -t qrsql -f Dockerfile.mysql .
#docker run --restart unless-stopped -d --name qrsql -p 3308:3308 qrsql

```

```bash 
# UPDATED DOCKERFILE

# Use the official Ubuntu 20.04 base image
FROM ubuntu:22.04

# Set non-interactive mode during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary packages
RUN apt-get update && \
    apt-get install -y git php php-gd php-xml php-mysql composer nodejs npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the working directory to the Laravel project directory
WORKDIR /var/www/html

# Copy your Laravel project files into the container
COPY . .

# Install PHP dependencies using Composer
RUN composer install

# Generate Laravel application key
RUN php artisan key:generate

# Install Node.js dependencies
RUN npm install

# Expose port 8000 for the Laravel development server
EXPOSE 8000

# Start the Laravel development server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]

```


docker run --restart unless-stopped -it -d --name qrgen -p 8082:8082 --link qrsql:qrsql qrgen

