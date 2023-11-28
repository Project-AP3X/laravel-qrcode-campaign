# Use the official Ubuntu 20.04 base image
FROM ubuntu:20.04

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
EXPOSE 8082

# Start the Laravel development server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8082"]
