<?php
/**
 * WordPress Configuration for Kubernetes Deployment
 * 
 * This file is configured to read database credentials from environment variables
 * which are injected by Kubernetes secrets/configmaps
 */

// ** Database settings - Read from environment variables ** //
define( 'DB_NAME', getenv('WORDPRESS_DB_NAME') ?: 'wordpress' );
define( 'DB_USER', getenv('WORDPRESS_DB_USER') ?: 'wordpress' );
define( 'DB_PASSWORD', getenv('WORDPRESS_DB_PASSWORD') ?: 'wordpress' );
define( 'DB_HOST', getenv('WORDPRESS_DB_HOST') ?: 'mysql-service' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );

/**
 * Authentication Unique Keys and Salts.
 * 
 * Change these to different unique phrases in production!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 */
define( 'AUTH_KEY',         getenv('WORDPRESS_AUTH_KEY') ?: 'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  getenv('WORDPRESS_SECURE_AUTH_KEY') ?: 'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    getenv('WORDPRESS_LOGGED_IN_KEY') ?: 'put your unique phrase here' );
define( 'NONCE_KEY',        getenv('WORDPRESS_NONCE_KEY') ?: 'put your unique phrase here' );
define( 'AUTH_SALT',        getenv('WORDPRESS_AUTH_SALT') ?: 'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', getenv('WORDPRESS_SECURE_AUTH_SALT') ?: 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   getenv('WORDPRESS_LOGGED_IN_SALT') ?: 'put your unique phrase here' );
define( 'NONCE_SALT',       getenv('WORDPRESS_NONCE_SALT') ?: 'put your unique phrase here' );

/**
 * WordPress Database Table prefix.
 */
$table_prefix = getenv('WORDPRESS_TABLE_PREFIX') ?: 'wp_';

/**
 * For developers: WordPress debugging mode.
 */
define( 'WP_DEBUG', getenv('WORDPRESS_DEBUG') === 'true' );
define( 'WP_DEBUG_LOG', getenv('WORDPRESS_DEBUG_LOG') === 'true' );
define( 'WP_DEBUG_DISPLAY', false );

/**
 * Performance optimizations
 */
define( 'WP_MEMORY_LIMIT', '256M' );
define( 'WP_MAX_MEMORY_LIMIT', '512M' );
define( 'AUTOSAVE_INTERVAL', 300 );
define( 'WP_POST_REVISIONS', 5 );
define( 'EMPTY_TRASH_DAYS', 30 );

/**
 * Security settings
 */
define( 'DISALLOW_FILE_EDIT', true );
define( 'FORCE_SSL_ADMIN', false );

/**
 * Redis Object Cache (if available)
 */
if ( getenv('REDIS_HOST') ) {
    define( 'WP_REDIS_HOST', getenv('REDIS_HOST') );
    define( 'WP_REDIS_PORT', getenv('REDIS_PORT') ?: 6379 );
    define( 'WP_CACHE', true );
}

/**
 * Absolute path to the WordPress directory.
 */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
