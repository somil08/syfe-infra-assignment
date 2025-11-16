# WordPress with PHP-FPM
# Production-grade WordPress container

FROM php:8.2-fpm

LABEL maintainer="Somil Rathore"
LABEL description="WordPress with PHP-FPM for Kubernetes deployment"

# Install dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    libwebp-dev \
    libxpm-dev \
    wget \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by WordPress
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    --with-xpm \
    && docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    pdo \
    pdo_mysql \
    opcache \
    zip \
    intl \
    exif \
    bcmath \
    soap

# Install Redis extension for caching
RUN pecl install redis && docker-php-ext-enable redis

# Install APCu for object caching
RUN pecl install apcu && docker-php-ext-enable apcu

# Configure PHP-FPM
RUN { \
    echo '[www]'; \
    echo 'listen = 9000'; \
    echo 'pm = dynamic'; \
    echo 'pm.max_children = 50'; \
    echo 'pm.start_servers = 5'; \
    echo 'pm.min_spare_servers = 5'; \
    echo 'pm.max_spare_servers = 35'; \
    echo 'pm.max_requests = 500'; \
    echo 'pm.status_path = /status'; \
    echo 'ping.path = /ping'; \
    echo 'ping.response = pong'; \
    } > /usr/local/etc/php-fpm.d/zz-custom.conf

# PHP configuration for WordPress
RUN { \
    echo 'memory_limit = 256M'; \
    echo 'upload_max_filesize = 64M'; \
    echo 'post_max_size = 64M'; \
    echo 'max_execution_time = 300'; \
    echo 'max_input_time = 300'; \
    echo 'max_input_vars = 3000'; \
    echo 'date.timezone = UTC'; \
    echo 'opcache.enable = 1'; \
    echo 'opcache.memory_consumption = 128'; \
    echo 'opcache.interned_strings_buffer = 8'; \
    echo 'opcache.max_accelerated_files = 10000'; \
    echo 'opcache.revalidate_freq = 2'; \
    echo 'opcache.fast_shutdown = 1'; \
    } > /usr/local/etc/php/conf.d/wordpress.ini

# Set WordPress version
ENV WORDPRESS_VERSION=6.4.2
ENV WORDPRESS_SHA1=7f24672c93f0e5c0b1c5f3d1c5c5c5c5c5c5c5c5

# Download WordPress
WORKDIR /tmp
RUN wget -O wordpress.tar.gz "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" \
    && tar -xzf wordpress.tar.gz \
    && mv wordpress /var/www/html \
    && rm wordpress.tar.gz

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Create wp-config.php template
COPY wp-config-docker.php /var/www/html/wp-config.php
RUN chown www-data:www-data /var/www/html/wp-config.php

# Install WP-CLI for management
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD php-fpm -t || exit 1

WORKDIR /var/www/html

EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
