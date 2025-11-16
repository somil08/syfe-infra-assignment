# MySQL 8.0 for WordPress
# Production-grade MySQL container with optimizations

FROM mysql:8.0

LABEL maintainer="Somil Rathore"
LABEL description="MySQL 8.0 optimized for WordPress on Kubernetes"

# Install additional tools
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Custom MySQL configuration for WordPress
COPY my.cnf /etc/mysql/conf.d/wordpress.cnf

# Create initialization script
COPY init-wordpress.sql /docker-entrypoint-initdb.d/

# Set proper permissions
RUN chmod 644 /etc/mysql/conf.d/wordpress.cnf

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} || exit 1

EXPOSE 3306

# Use the default MySQL entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mysqld"]
