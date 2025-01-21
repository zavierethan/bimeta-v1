#LABEL authors="robya"
FROM php:7.4-apache

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    npm \
    curl \
    vim \
    && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN a2enmod rewrite

# # Copy custom Apache configuration file
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql zip

# Set working directory
WORKDIR /var/www/html

# Copy composer files and install dependencies
COPY composer.* ./
RUN composer install --no-scripts --no-autoloader

# Copy npm files and install dependencies
COPY package*.json ./
RUN npm install

# Copy Laravel project files
COPY . .

# Generate Laravel mix assets
# RUN npm run build

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

RUN service apache2 restart

# Expose port
EXPOSE 8081

# Start Apache
CMD ["apache2-foreground"]
