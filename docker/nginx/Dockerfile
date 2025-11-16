# OpenResty Nginx with Lua Support
# Production-grade Nginx with OpenResty for WordPress proxy

FROM ubuntu:22.04

LABEL maintainer="Somil Rathore"
LABEL description="OpenResty Nginx with Lua for WordPress proxy"

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    libgd-dev \
    libgeoip-dev \
    libxml2 \
    libxml2-dev \
    libxslt1-dev \
    libpq-dev \
    wget \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set OpenResty version
ENV OPENRESTY_VERSION=1.21.4.3

# Download and extract OpenResty
WORKDIR /tmp
RUN wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz \
    && tar -xzf openresty-${OPENRESTY_VERSION}.tar.gz \
    && cd openresty-${OPENRESTY_VERSION}

# Build OpenResty with specified configure options
WORKDIR /tmp/openresty-${OPENRESTY_VERSION}
RUN ./configure \
    --prefix=/opt/openresty \
    --with-pcre-jit \
    --with-ipv6 \
    --without-http_redis2_module \
    --with-http_iconv_module \
    --with-http_postgres_module \
    -j8 \
    && make -j8 \
    && make install

# Clean up build files
RUN rm -rf /tmp/openresty-${OPENRESTY_VERSION}*

# Create nginx user
RUN useradd -r -s /bin/false nginx

# Create necessary directories
RUN mkdir -p /var/log/nginx /var/cache/nginx /opt/openresty/nginx/conf/conf.d

# Copy nginx configuration
COPY nginx.conf /opt/openresty/nginx/conf/nginx.conf
COPY wordpress.conf /opt/openresty/nginx/conf/conf.d/wordpress.conf

# Create lua scripts directory
RUN mkdir -p /opt/openresty/nginx/lua

# Copy Lua scripts for monitoring and request handling
COPY lua/metrics.lua /opt/openresty/nginx/lua/metrics.lua
COPY lua/request_logger.lua /opt/openresty/nginx/lua/request_logger.lua

# Set proper permissions
RUN chown -R nginx:nginx /var/log/nginx /var/cache/nginx /opt/openresty/nginx

# Expose ports
EXPOSE 80 9145

# Add PATH
ENV PATH="/opt/openresty/nginx/sbin:${PATH}"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Run as nginx user
USER nginx

# Start OpenResty
CMD ["/opt/openresty/nginx/sbin/nginx", "-g", "daemon off;"]
