# Use official PHP Apache image
FROM php:7.2-apache

# Install system dependencies and Composer
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    git \
    unzip && \
    docker-php-ext-configure zip && \
    docker-php-ext-install gd pdo pdo_mysql zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable mod_rewrite for Apache
RUN a2enmod rewrite

# Copy the Laravel project to the Apache web directory
COPY . /var/www/html

# Set working directory to Laravel project
WORKDIR /var/www/html

RUN composer clear-cache
RUN rm -rf vendor composer.lock

# Run Composer install to install PHP dependencies
RUN composer install --no-interaction --prefer-dist
# Set file permissions
RUN git config --global --add safe.directory /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Set proper permissions for storage and bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Configure Apache to use /public as the DocumentRoot
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80
