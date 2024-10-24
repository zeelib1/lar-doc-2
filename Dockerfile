# Use the official PHP 8.2 image with FPM
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libpq-dev \
    zip \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql mbstring gd bcmath

# Update Composer installation
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy existing application directory contents
COPY . /var/www

# Set correct permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache

# Install application dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy custom php-fpm configuration
COPY php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Expose port 9001
EXPOSE 9001

# Start PHP-FPM
CMD ["php-fpm", "-F", "--nodaemonize"]

# Copy mime.types file
COPY mime.types /etc/nginx/mime.types
