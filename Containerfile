# FROM docker.io/library/wordpress:6.8.0-php8.3-apache

# # 1. Copy PHP development ini file to production
# RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

# # 2. Configure Apache upload limits
# RUN echo "LimitRequestBody 67108864" > /etc/apache2/conf-available/upload-size.conf && \
#     a2enconf upload-size

# # 3. Set PHP custom limits
# RUN printf "upload_max_filesize = 64M\npost_max_size = 64M\nmemory_limit = 128M\n" \
#     >> /usr/local/etc/php/conf.d/99-custom-limits.ini



# Use the official WordPress image with PHP 8.3 and Apache
FROM docker.io/library/wordpress:6.8.0-php8.3-apache

# Metadata (optional but useful)
LABEL maintainer="chmabuen@espol.edu.ec"
LABEL description="Custom WordPress image with increased upload limits for Elementor plugin and SOAP enabled"

# Environment variables for PHP limits (easy to tweak)
ENV PHP_UPLOAD_LIMIT=64M \
    PHP_POST_LIMIT=64M \
    PHP_MEMORY_LIMIT=128M

# Install php-soap and configure upload limits
RUN set -eux; \
    \
    # Install dependencies and php-soap extension
    apt-get update; \
    apt-get install -y --no-install-recommends libxml2-dev unzip; \
    docker-php-ext-install soap; \
    \
    # Clean up
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    \
    # Use production PHP config as base
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini; \
    \
    # Configure Apache to allow larger POST requests
    echo "LimitRequestBody 67108864" > /etc/apache2/conf-available/upload-size.conf; \
    a2enconf upload-size; \
    \
    # Configure PHP upload limits
    printf "upload_max_filesize = ${PHP_UPLOAD_LIMIT}\npost_max_size = ${PHP_POST_LIMIT}\nmemory_limit = ${PHP_MEMORY_LIMIT}\n" \
        > /usr/local/etc/php/conf.d/99-custom-limits.ini

# Copy and unzip the Motta theme into wp-content
COPY motta.zip /tmp/motta.zip

RUN set -eux; \
    unzip /tmp/motta.zip -d /var/www/html/wp-content/themes/; \
    rm /tmp/motta.zip
