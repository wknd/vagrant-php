CREATE USER IF NOT EXISTS 'forums'@'localhost' IDENTIFIED BY '6hgQJiDxx5VgY9UhAx';
CREATE DATABASE IF NOT EXISTS phpbb;
GRANT ALL PRIVILEGES ON phpbb.* to 'forums'@'localhost';

