/* Создание базы данных приемной комиссии */
CREATE DATABASE admission_office 
	OWNER postgres ENCODING 'UTF8';
	
/* Подключение к созданной базе данных */
/* Встроенная команда psql */
\c admission_office

/* Объявление перечислений */
CREATE TYPE typeofquota AS ENUM
('Special','Target');
CREATE TYPE benefitcode AS ENUM
('AWE4AnySpec','AWE4SomeSpec');
CREATE TYPE typeofpaymentmethod AS ENUM
('Budget','Contract');
CREATE TYPE documentofeducation AS ENUM
('At11','SPO','VO');

/* Функция для добавления данных из csv-файлов */
/* На языке PL/pgSQL */
CREATE FUNCTION loaddata(csvfilename TEXT, updcounter BOOLEAN) 
RETURNS void
AS $$
/* Cимвол начала/конца строки, аналог апострофа */
/* Обязательный раздел объявления переменных */
DECLARE tablename TEXT;
BEGIN
	/* Обращение к функциям */
	tablename:=LOWER(csvfilename);
	/* Выполнения запроса из строки (text) */
	/* || - оператор конкатенации строк */
	EXECUTE 'copy ' || tablename || ' from ' ||
	' ''/home/user1/text/edu/VSTU/Базы данных/ЛР2/DATA/'||
	csvfilename ||'.csv'' delimiter '','' NULL AS ''NULL'';';
	/* Вывод сообщений */
	RAISE NOTICE 'Информация загружена';
	
	/* Условия */
	/* Напоминают таковые в Visual Basic */
	/* Если требуется обнулить счетчик автоинкрементального поля
		то обнуляем его */
	IF updcounter=TRUE 
	THEN 
	  EXECUTE 'SELECT setval(''' || tablename 
	  || '_id_seq'',max(id)) FROM '|| tablename;
	  RAISE NOTICE 'Автоинкрементальный счетчик обнулен';
	END IF;
END;
$$
LANGUAGE plpgsql;

/* Создание таблиц и одновременное наполнение из csv-файлов */
/* Схема по умолчанию - public */
CREATE TABLE branch (
	   id smallserial,
	   PRIMARY KEY (id),
	   name varchar(150)
);
/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('Branch',TRUE);

CREATE TABLE faculty (
	   id smallserial,
	   PRIMARY KEY (id),
	   id_branch smallserial NOT NULL REFERENCES branch
	   ON DELETE CASCADE,
	   name varchar(150)
);
/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('Faculty',TRUE);

CREATE TABLE typeofeducation (
	   id smallserial,
	   PRIMARY KEY (id),
	   trainingperiod real,
	   name varchar(50)
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('TypeOfEducation',TRUE);

CREATE TABLE paymentmethod (
	   id smallserial,
	   PRIMARY KEY (id),
	   paymentmethodtype typeofpaymentmethod
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('PaymentMethod',TRUE);

CREATE TABLE subject (
	 id serial,
	 PRIMARY KEY (id),
	 name varchar(80),
	 minimumegescore smallint 
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('Subject',TRUE);

CREATE TABLE speciality (
	 speciality_code char(10),
	 PRIMARY KEY (speciality_code),
	 subject_vips integer NOT NULL REFERENCES subject
	 ON DELETE SET NULL,
	 name varchar(200)
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('Speciality',FALSE);

CREATE TABLE educationalprogram (
	   id serial,
	   PRIMARY KEY (id),
	   id_formofeducation smallint NOT NULL REFERENCES typeofeducation
	   ON DELETE CASCADE,
	   speciality_code char(10) NOT NULL REFERENCES speciality
	   ON DELETE CASCADE
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('EducationalProgram',TRUE);

CREATE TABLE paymentmethod2educationalprogram (
	 id serial,
	 PRIMARY KEY (id),
	 id_faculty smallint NOT NULL REFERENCES faculty
	 ON DELETE CASCADE,
	 id_paymentmethod integer NOT NULL REFERENCES paymentmethod
	 ON DELETE CASCADE,
	 id_educationalprogram integer NOT NULL REFERENCES educationalprogram
	 ON DELETE CASCADE,
	 price money,
	 numberofstudents smallint
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('PaymentMethod2EducationalProgram',TRUE);

CREATE TABLE quota (
	 id serial,
	 PRIMARY KEY (id),
	 id_faculty smallint NOT NULL REFERENCES faculty
	 ON DELETE CASCADE,
	 id_educationalprogram integer NOT NULL REFERENCES educationalprogram
	 ON DELETE CASCADE,
	 numberofstudents smallint,
	 quotatype typeofquota
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('Quota',TRUE);

CREATE TABLE subject2specialityege (
	 speciality_code char(10) NOT NULL REFERENCES speciality
	 ON DELETE CASCADE,
	 idsubject integer NOT NULL REFERENCES subject 
	 ON DELETE SET NULL,
	 PRIMARY KEY (speciality_code, idsubject)
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('Subject2SpecialityEGE',FALSE);

CREATE TABLE benefitsforthewinners (
	 id smallserial,
	 PRIMARY KEY (id),
	 bc benefitcode,
	 minimumegescore smallint
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('BenefitsForTheWinners',TRUE);

CREATE TABLE olympiad (
	 id serial,
	 PRIMARY KEY (id),
	 name varchar(150),
	 idbenefits smallint NOT NULL REFERENCES benefitsforthewinners
	 ON DELETE CASCADE
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('Olympiad',TRUE);

CREATE TABLE olympiadcertificate (
	 id serial,
	 PRIMARY KEY (id),
	 id_olympiad integer NOT NULL REFERENCES olympiad
	 ON DELETE CASCADE,
	 idsubject integer NOT NULL REFERENCES subject
	 ON DELETE CASCADE
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('OlympiadCertificate',TRUE);

CREATE TABLE olympiadcertificate2speciality (
	 id_olympiadcertificate integer NOT NULL REFERENCES olympiadcertificate
	 ON DELETE CASCADE,
	 speciality_code char(10) NOT NULL REFERENCES speciality
	 ON DELETE CASCADE,
	 PRIMARY KEY (id_olympiadcertificate,speciality_code)
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('OlympiadCertificate2Speciality',FALSE);

CREATE TABLE citizenship (
	 id smallserial,
	 PRIMARY KEY (id),
	 name varchar(100),
	 agreementwithrf boolean
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('Citizenship',TRUE);

CREATE TABLE enrollee (
	 id serial,
	 PRIMARY KEY (id),
	 name varchar(100),
	 dob date,
	 educationaldocument documentofeducation,
	 achievementpoints smallint,
	 righttospecialquota boolean,
	 agreementontargettraining boolean,
	 righttopriorityadmission boolean,
	 disabled boolean,
	 compatriot boolean
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('Enrollee',TRUE);

CREATE TABLE enrollee2citizenship (
	 id_enrollee integer NOT NULL REFERENCES enrollee
	 ON DELETE CASCADE,
	 id_citizenship integer NOT NULL REFERENCES citizenship
	 ON DELETE CASCADE,
	 PRIMARY KEY (id_enrollee,id_citizenship)
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('Enrollee2Citizenship',FALSE);

CREATE TABLE receivedcertificate (
	 id_enrollee integer NOT NULL REFERENCES enrollee
	 ON DELETE CASCADE,
	 id_olympiadcertificate integer NOT NULL REFERENCES olympiadcertificate
	 ON DELETE CASCADE,
	 PRIMARY KEY (id_enrollee, id_olympiadcertificate),
	 dateofreceiving date
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('ReceivedCertificate',FALSE);

CREATE TABLE passedege (
	 id serial,
	 PRIMARY KEY (id),
	 id_enrollee integer NOT NULL REFERENCES enrollee
	 ON DELETE CASCADE,
	 id_subject integer NOT NULL REFERENCES subject
	 ON DELETE SET NULL,
	 dateofexam date,
	 score smallint
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('PassedEGE',TRUE);

CREATE TABLE passedvips (
	 id serial,
	 PRIMARY KEY (id),
	 id_enrollee integer NOT NULL REFERENCES enrollee
	 ON DELETE CASCADE,
	 id_subject integer NOT NULL REFERENCES subject
	 ON DELETE CASCADE,
	 score smallint
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('PassedVIPS',TRUE);

CREATE TABLE application (
	 id serial,
	 PRIMARY KEY (id),
	 id_faculty smallint NOT NULL REFERENCES faculty
	 ON DELETE CASCADE,
	 id_paymentmethod smallint NOT NULL REFERENCES paymentmethod
	 ON DELETE CASCADE,
	 id_quota integer REFERENCES quota
	 ON DELETE CASCADE,
	 id_educationalprogram integer NOT NULL REFERENCES educationalprogram
	 ON DELETE CASCADE,
	 id_enrollee integer NOT NULL REFERENCES enrollee
	 ON DELETE CASCADE,
	 enrolmentconsent boolean
);

/* Загрузка данных из csv-файла */
/* Вызов функции */
SELECT loaddata('Application',TRUE);

/* Удаляем функцию добавления данных для большей безопасности */
DROP FUNCTION loaddata(csvfilename TEXT, updcounter BOOLEAN);

/* Отключиться от базы */
\q
