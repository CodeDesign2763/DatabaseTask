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
	id_event bigint ,
	id_employee integer,
	PRIMARY KEY (id_event, id_employee)
);

CREATE TABLE  exhibit (
	id serial,
	PRIMARY KEY (id),
	name varchar(100),
	dataoforigin date,
	description text,
	id_showroom smallint  REFERENCES showroom
);

CREATE TABLE  exhibit2event (
	id_exhibit integer,
	id_event bigint,
	PRIMARY KEY (id_exhibit, id_event),
);







