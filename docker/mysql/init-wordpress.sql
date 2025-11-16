-- WordPress Database Initialization Script
-- This script runs automatically when the container starts for the first time

-- Create WordPress database if it doesn't exist
CREATE DATABASE IF NOT EXISTS wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges (user is created by environment variables)
-- This is handled by the MySQL Docker image automatically
-- GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%';
-- FLUSH PRIVILEGES;

-- Use WordPress database
USE wordpress;

-- Create a table for health checks (optional)
CREATE TABLE IF NOT EXISTS health_check (
    id INT AUTO_INCREMENT PRIMARY KEY,
    check_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert initial health check record
INSERT INTO health_check (status) VALUES ('initialized');
