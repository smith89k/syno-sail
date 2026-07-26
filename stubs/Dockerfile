# ==========================================
# Stage 1: Build Frontend Assets with Node
# ==========================================
FROM node:20-alpine AS frontend
WORKDIR /app
# Copy package files and install dependencies
COPY package.json package-lock.json* ./
RUN npm ci || npm install
# Copy the rest of the code and build Vite assets
COPY . .
RUN npm run build


# ==========================================
# Stage 2: Build PHP/Laravel Application
# ==========================================
FROM php:8.4-fpm

COPY docker/php/php.ini /usr/local/etc/php/conf.d/custom.ini

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    libzip-dev \
    libonig-dev && \
    docker-php-ext-install \
    pdo_mysql \
    bcmath \
    fileinfo \
    mbstring \
    exif \
    pcntl \
    zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY docker/php/php.ini /tmp/php.ini
COPY docker/nginx/nginx.conf /tmp/nginx.conf

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY docker/scripts/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /var/www

RUN mkdir -p storage/framework/views storage/framework/cache storage/framework/sessions storage/logs storage/app bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

COPY composer.json composer.lock ./
RUN composer install --no-dev --ignore-platform-reqs --no-interaction --no-autoloader --no-scripts

COPY . .

# ---> INJECT COMPILED ASSETS FROM STAGE 1 <---
COPY --from=frontend /app/public/build ./public/build

RUN composer dump-autoload --no-dev --optimize --ignore-platform-reqs

RUN chmod -R 775 storage bootstrap/cache

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD php-fpm -t || exit 1

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["php-fpm"]