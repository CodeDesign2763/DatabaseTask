/* Удалить БД доп. задания, если она создана */
DROP DATABASE IF EXISTS addtask;

/* Создание базы данных из дополнительного задания */
CREATE DATABASE addtask 
	OWNER postgres ENCODING 'UTF8';
	
/* Подключение к созданной базе данных */
/* Встроенная команда psql */
\c addtask

/* Создание таблицы */
CREATE TABLE  employee (
	id serial,
	/* Указание первичного ключа */
	PRIMARY KEY (id),
	fullname varchar(100),
	phone varchar(200),
	adress varchar(200)
);
CREATE TABLE  event (
	id bigserial,
	PRIMARY KEY (id),
	name varchar(100),
	startdate date,
	enddate date,
	description text
);

CREATE TABLE  building (
	id smallserial,
	PRIMARY KEY (id),
	adress varchar(100),
	name varchar(100),
	phone varchar(30),
	/* Указание внешнего ключа */
	/* По умолчанию он может принимать значение NULL */
	id_employee integer  NOT NULL REFERENCES employee
);

CREATE TABLE  showroom (
	id smallserial,
	PRIMARY KEY (id),
	name varchar(100),
	id_employee integer  NOT NULL REFERENCES employee,
	id_building smallint  NOT NULL REFERENCES building
);

CREATE TABLE  event2employee (
	id_event bigint NOT NULL REFERENCES event,
	id_employee integer NOT NULL REFERENCES employee,
	PRIMARY KEY (id_event, id_employee)
);

CREATE TABLE  exhibit (
	id serial,
	PRIMARY KEY (id),
	name varchar(100),
	dateoforigin date,
	description text,
	id_showroom smallint  REFERENCES showroom
);

CREATE TABLE  exhibit2event (
	id_exhibit integer NOT NULL REFERENCES exhibit,
	id_event bigint NOT NULL REFERENCES event,
	PRIMARY KEY (id_exhibit, id_event)
);

/* alter table */

/* Добавить к таблице building
	атрибут price типа money 
	с ограничением NOT NULL */
ALTER TABLE building ADD COLUMN
price money NOT NULL;
/* Вывод сообщения */
SELECT 'Добавлен атрибут price' as Сообщение;
/* Вывод информации о таблице на экран
	(встроенная команда в psql) */
\d building

/* Измение типа атрибута в таблице */
/* Сперва ради эксперимента добавим в building
	какие-то данные */
/* Для этого придется сначала добавить данные 
	в таблицу employee, чтобы можно было 
	назначить ответственного сотрудника */
/* Вставка данных в таблицу employee */
INSERT INTO employee (id, fullname, phone, adress) 
VALUES (default,'Иванов И. И.', '22-22-22',
	'ул. Танкистов 22, дом 22');
/* Теперь уже добавим данные в building */
INSERT INTO building (id, adress, name, phone, id_employee, price) 
VALUES (default, 'ул. Кирова, д. 1', 
'Главный музейный корпус',
	'11-11-11', 1, 200000.25);
/* Посмотрим, корректно ли пройдет преобразование 
	money --> varchar(100) */
ALTER TABLE building ALTER COLUMN price SET DATA TYPE varchar(100);
/* Вывод сообщения */
SELECT 'Преобразование money-->varchar(100)' as Сообщение;
SELECT * FROM building;
\d building

/* Проверка обратного преобразования 
	varchar(100) --> money */
ALTER TABLE building ALTER COLUMN price 
SET DATA TYPE money USING price::money;
SELECT 'Обратное преобразование типа атрибута' as Сообщение;
\d building
SELECT * FROM building;

/* Удалить атрибут из таблицы */
ALTER TABLE building DROP COLUMN price;
SELECT 'Удаление атрибута price из таблицы' as Сообщение;
\d building;

/* Установка ограничения NOT NULL для атрибута */
ALTER TABLE building ALTER COLUMN phone SET NOT NULL;
SELECT 'Установка ограничения NOT NULL для атрибута phone' 
as Сообщение;
\d building;
/* Удаление ограничения NOT NULL для атрибута */
ALTER TABLE building ALTER COLUMN phone DROP NOT NULL;
SELECT 'Удаление ограничения NOT NULL для атрибута phone' 
as Сообщение;
\d building


/* Установить значение атрибута по умолчанию */
ALTER TABLE building ALTER COLUMN 
phone SET DEFAULT '29-29-29';
SELECT 'Установить значение атрибута phone по умолчанию' 
as Сообщение;
\d building
ALTER TABLE building ALTER COLUMN 
phone SET DEFAULT '29-29-29';
/* Удалить значение атрибута по умолчанию */
ALTER TABLE building ALTER COLUMN
phone DROP DEFAULT;
SELECT 'Удаление значения атрибута phone по умолчанию' 
as Сообщение;
\d building

/* Создадим еще одну таблицу для экспериментов */
CREATE TABLE testtable (atr1 varchar(20),atr2 integer);
/* Добавление в таблицу первичного ключа */
ALTER TABLE testtable ADD PRIMARY KEY (atr1);
/* Добавление в таблицу внешнего ключа */
ALTER TABLE testtable ADD FOREIGN KEY (atr2) references employee;
SELECT 'Добавление первичного и внешнего ключа' 
as Сообщение;
\d testtable;
/* Удаление таблицы */
DROP TABLE testtable;

/* Добавление данных при помощи запросов insert */
/* Добавим еще 1 сотрудника */
INSERT INTO employee (id, fullname, phone, adress) 
VALUES 
(default,'Петров П. П.', '33-33-33','ул. Строителей 33, дом 33');

/* Добавим еще 1 экземпляр сущности building */
INSERT INTO building 
(id, adress, name, phone, id_employee) 
VALUES 
(default, 'ул. Королева, д. 8',
'Новый музейный корпус', '55-55-55', 2);
SELECT * FROM building;

/* Добавим по выставочному залу в каждое здание */
INSERT INTO showroom (id, name, id_employee, id_building) 
VALUES 
(default, 'Зал истории средних веков', 1,1);
INSERT INTO showroom 
(id, name, id_employee, id_building) 
VALUES 
(default, 'Зал истории Второй мировой войны', 2,2);
SELECT * FROM showroom;

/* Добавим 2 экспоната */
INSERT INTO 
exhibit 
(id,name,dateoforigin,description,id_showroom) 
VALUES 
(default, 'Экскалибур', '600-01-01', 
'Легендарный меч, заключенный в камень. 
Найден при строительстве торгового центра.',1); 
INSERT INTO 
exhibit (id,name,dateoforigin,description,id_showroom) 
VALUES 
(default, 'ППС-43', '1944-03-20', 
'Пистолет-пулемет Судаева ППС-43',2); 
SELECT * FROM exhibit;

/* Добавим 2 исторических события */
INSERT INTO
event (id,name,startdate,enddate,description)
VALUES
(default,'Первая мировая война', '1914-07-28',
'1918-11-11','Одна из самых 
широкомасштабных войн в истории человечества');
INSERT INTO
event (id,name,startdate,enddate,description)
VALUES
(default,'Вторая мировая война', '1939-09-01',
'1945-09-12','Крупнейший вооруженный конфликт 
в истории человечества');
SELECT * FROM event;

/* Оба события изучаются сотрудником №2 */
INSERT INTO
event2employee (id_event,id_employee)
VALUES
(1,2);
INSERT INTO
event2employee (id_event,id_employee)
VALUES
(2,2);
SELECT * FROM  event2employee;

/* Переименование таблицы */
-- ALTER TABLE event 
-- RENAME TO historical_event;
-- SELECT 'Переименование таблицы' 
-- as Сообщение;
-- \d historical_event

/* Переименование столбца */
-- ALTER TABLE historical_event 
-- RENAME COLUMN 
-- name 
-- TO event_name;
-- SELECT 'Переименование атрибута таблицы' 
-- as Сообщение;
-- \d historical_event

/* Отключиться от БД */
\q

