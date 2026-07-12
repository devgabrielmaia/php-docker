############################################
# BASE
############################################
FROM php:8.3-fpm-alpine3.20 AS base
LABEL maintainer="Gabriel Maia"
WORKDIR /var/www

# System dependencies
RUN apk add --no-cache \
    bash \
    icu-dev \
    oniguruma-dev \
    libzip-dev \
    postgresql-dev \
    postgresql16-client \
    libpng-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    unzip \
    zip

# PHP extensions
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg
RUN docker-php-ext-install \
    pdo_pgsql \
    pgsql \
    mbstring \
    intl \
    zip \
    gd \
    opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# PHP configuration
COPY config/php.ini /usr/local/etc/php/conf.d/app.ini
COPY config/zz-custom.conf /usr/local/etc/php-fpm.d/zz-custom.conf

############################################
# FRONTEND BUILDER
############################################
# FROM node:20-alpine AS frontend-builder
# WORKDIR /app
# ENV NODE_OPTIONS=--openssl-legacy-provider
# COPY package*.json ./
# RUN npm ci --no-audit --no-fund
# COPY webpack.mix.js ./
# COPY artisan ./
# COPY resources ./resources
# COPY public ./public
# RUN npm run production

############################################
# RUNNER (CI/CD)
############################################
FROM base AS runner
WORKDIR /var/www

COPY composer.* ./

# Install dependencies with dev packages (--no-scripts: artisan ainda não existe nesta camada)
RUN --mount=type=cache,target=/tmp/composer-cache \
    composer install \
    --prefer-dist \
    --no-interaction \
    --no-progress \
    --no-scripts

COPY . .
# COPY --from=frontend-builder /app/public ./public
COPY .env.example .env

RUN composer dump-autoload --optimize --no-interaction

RUN php artisan key:generate || true

############################################
# BUILDER (PRODUCTION)
############################################
FROM base AS builder

WORKDIR /var/www

COPY composer.* ./

# Install production dependencies only (--no-scripts: artisan ainda não existe nesta camada)
RUN --mount=type=cache,target=/tmp/composer-cache \
    composer install \
    --no-dev \
    --prefer-dist \
    --optimize-autoloader \
    --classmap-authoritative \
    --no-interaction \
    --no-progress \
    --no-scripts

COPY . .
# COPY --from=frontend-builder /app/public ./public

RUN composer dump-autoload \
    --optimize \
    --classmap-authoritative \
    --no-dev \
    --no-interaction

RUN rm -rf \
    tests \
    node_modules \
    docker \
    .git \
    storage/logs/* \
    bootstrap/cache/* \
    .env \
    .env.* \
    phpunit.xml \
    phpunit.xml.dist \
    /root/.composer/cache \
    /tmp/*
RUN rm -f /usr/bin/composer

USER www-data
EXPOSE 9000
CMD ["php-fpm"]