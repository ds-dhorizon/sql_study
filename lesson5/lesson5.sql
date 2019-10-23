/* УРОК 5 */

CREATE DATABASE IF NOT EXISTS lesson5;
USE lesson5;

/*
Пусть в таблице users поля created_at и updated_at оказались незаполненными.
Заполните их текущими датой и временем.
 */

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT NULL,
  updated_at DATETIME DEFAULT NULL
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

UPDATE
	users
SET created_at = NOW(),
	updated_at = NOW()
WHERE created_at <=> NULL and updated_at <=> NULL

SELECT * FROM users;

/*
Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы
типом VARCHAR и в них долгое время помещались значения в формате "20.10.2017 8:10".
Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.
 */


DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(50) DEFAULT NULL,
  updated_at VARCHAR(50) DEFAULT NULL
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
  ('Геннадий', '1990-10-05', '20.10.2013 8:08', '10.10.2014 14:10'),
  ('Наталья', '1984-11-12', '14.08.2017 13:17', '10.05.2018 22:10'),
  ('Александр', '1985-05-20', '09.08.2017 3:25', '31.12.2018 5:10'),
  ('Сергей', '1988-02-14', '14.08.2017 15:10', '10.05.2018 22:10'),
  ('Иван', '1998-01-12', '20.10.2013 16:34', '10.10.2014 14:10'),
  ('Мария', '1992-08-29', '14.08.2017 4:45', '10.05.2018 22:10');


ALTER TABLE users
	RENAME COLUMN updated_at TO updated_at_var,
	RENAME COLUMN created_at TO created_at_var;

ALTER TABLE users
	ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP AFTER updated_at_var,
	ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at_var;

UPDATE users
SET
	updated_at = STR_TO_DATE(created_at_var, '%e.%c.%Y %H:%i'),
	created_at = STR_TO_DATE(updated_at_var, '%e.%c.%Y %H:%i')
WHERE created_at <=> NULL and updated_at <=> NULL;

ALTER TABLE users
	DROP COLUMN updated_at_var,
	DROP COLUMN created_at_var;

SELECT * FROM users;
/*
В таблице складских запасов storehouses_products
в поле value могут встречаться самые разные цифры: 0,
если товар закончился и выше нуля, если на складе имеются запасы.
Необходимо отсортировать записи таким образом, чтобы они выводились
в порядке увеличения значения value. Однако, нулевые запасы должны выводиться в конце,
после всех записей.
*/

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

INSERT INTO storehouses_products(storehouse_id, product_id, value)
VALUES
('1', '12', '0'),
('1', '32', '10'),
('3', '2', '125'),
('2', '4', '141'),
('2', '17', '0'),
('2', '121', '0'),
('2', '93', '100'),
('3', '3', '120'),
('3', '17', '0'),
('2', '33', '1209'),
('1', '25', '0'),
('3', '25', '120');

SELECT *, value = 0 as is_zero FROM storehouses_products
ORDER BY is_zero, value
