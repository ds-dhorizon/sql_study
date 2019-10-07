/*
Создайте базу данных example, разместите в ней таблицу users, состоящую из двух столбцов, числового id и строкового name.
 */

CREATE DATABASE IF NOT EXISTS example;
USE example;
CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL COMMENT 'Username'
) COMMENT = 'Users';
