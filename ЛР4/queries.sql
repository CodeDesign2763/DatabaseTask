/* Удалить БД доп. задания, если она создана */

/* Подключение к созданной базе данных */
/* Встроенная команда psql */
\c admission_office

-- Update
select 'Уменьшим значение минимального балла ЕГЭ
 для олимпиад 2-го типа'
as Сообщение;
update benefitsforthewinners set minimumegescore=40 where id=2;
select * from benefitsforthewinners;

-- Запросы из функциональных требований XXXXX XXXXX XX
/* Справочные операции */
SELECT 'Запросы из ЛР №1' as Сообщение;

/* Функция, выводящая статистику по ЕГЭ */
/*		в виде двумерного массива varchar по номеру абитуриента */
CREATE OR REPLACE FUNCTION 
get_enr_ege_stat(integer) 
RETURNS varchar[] 
AS $$ 
/* :: - преобразование типов */
/* array_agg - агрегатная функция, добавляющая в массив
	все свои аргументы */
SELECT array_agg(ARRAY[left(subject.name,3)::varchar,passedege.score::varchar]) 
FROM enrollee JOIN passedege 
ON enrollee.id=passedege.id_enrollee 
JOIN subject 
ON subject.id=passedege.id_subject 
WHERE enrollee.id=$1 
$$ language sql;

/* Функция, выводящая статистику по ВИПС */
/*		в виде двумерного массива varchar по номеру абитуриента */
CREATE OR REPLACE FUNCTION 
get_enr_vips_stat(integer) 
RETURNS varchar[] 
AS $$ 
/* :: - преобразование типов */
/* array_agg - агрегатная функция, добавляющая в массив
	все свои аргументы */
SELECT array_agg(ARRAY[left(subject.name,3)::varchar,passedvips.score::varchar]) 
FROM enrollee JOIN passedvips 
ON enrollee.id=passedvips.id_enrollee 
JOIN subject 
ON subject.id=passedvips.id_subject 
WHERE enrollee.id=$1 
$$ language sql;

/* Функция, выводящая краткую статистику по олимпиадам
	по номеру абитуриента */
CREATE OR REPLACE FUNCTION 
get_enr_olymp_stat(integer) 
RETURNS varchar[] 
AS $$ 
SELECT array_agg(array[ol.id::varchar(10),left(subject.name,3)::varchar])
FROM enrollee 
JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
JOIN olympiadcertificate 
ON olympiadcertificate.id=receivedcertificate.id_olympiadcertificate 
JOIN subject 
ON subject.id=olympiadcertificate.idsubject 
JOIN olympiad as ol
on olympiadcertificate.id_olympiad=ol.id
WHERE enrollee.id=$1 
$$ 
LANGUAGE sql;

/* Вывести краткую информацию об абитуриенте,
	включая гражданство, сведения о результатах ЕГЭ,
	ВИПС, олимпиадах */
SELECT 'Краткая информация об абитуриенте' AS Сообщение;

SELECT DISTINCT enrollee.id AS "ID", 
enrollee.name AS "ФИО", 
(SELECT array_agg(cs.name) FROM enrollee 
AS enr1 JOIN enrollee2citizenship AS e2c 
ON enr1.id=e2c.id_enrollee JOIN citizenship AS cs 
ON e2c.id_citizenship=cs.id WHERE enr1.id=enrollee.id),
get_enr_ege_stat(enrollee.id) AS "Результаты ЕГЭ",
get_enr_vips_stat(enrollee.id) AS "Результаты ВИПС", 
get_enr_olymp_stat(enrollee.id) AS "Победитель олимпиад" 
FROM enrollee JOIN enrollee2citizenship 
ON enrollee.id=enrollee2citizenship.id_enrollee 
JOIN citizenship 
ON enrollee2citizenship.id_citizenship=citizenship.id 
WHERE (enrollee.id between 35 and 55) 
OR (enrollee.id between 75 and 80)
OR (enrollee.id between 130 and 145);	

/* Вывести совокупность информации по факультету:
	доступные образовательные программы с указанием формы и срока
	обучения, специальности, доступных способов финансирования 
	с указанием числа мест и способа финансирования */
	
/* Выполним такой запрос для факультета №1 */
SELECT 'Сведения по факультету №1' AS Сообщение;
SELECT educationalprogram.speciality_code AS "Код НП", 
typeofeducation.name AS "Форма обучения",
typeofeducation.trainingperiod AS "Срок обучения",
paymentmethod2educationalprogram.numberofstudents
AS "Число мест (Б)",
(SELECT pm2ep.numberofstudents 
from paymentmethod2educationalprogram AS pm2ep 
WHERE pm2ep.id_faculty=
paymentmethod2educationalprogram.id_faculty 
AND pm2ep.id_educationalprogram=
paymentmethod2educationalprogram.id_educationalprogram 
AND pm2ep.id_paymentmethod=2) AS "Число мест (К)",
q1.numberofstudents AS "Особая квота", 
q2.numberofstudents AS "Целевая квота" 
FROM paymentmethod2educationalprogram 
JOIN educationalprogram 
ON paymentmethod2educationalprogram.id_educationalprogram=
educationalprogram.id 
JOIN typeofeducation 
ON educationalprogram.id_formofeducation=typeofeducation.id 
JOIN paymentmethod 
ON paymentmethod2educationalprogram.id_paymentmethod=paymentmethod.id 
LEFT JOIN quota as q1 
ON q1.id_faculty=1 
AND q1.id_educationalprogram=educationalprogram.id 
AND q1.quotatype='Special' 
LEFT JOIN quota as q2 
ON q2.id_faculty=1 
AND q2.id_educationalprogram=educationalprogram.id 
AND q2.quotatype='Target' 
WHERE paymentmethod2educationalprogram.id_faculty=1
AND paymentmethod2educationalprogram.id_paymentmethod=1;

/* Разработаем функцию на основе данного запроса */
/* Проведем эксперимент с record - аналогом кортежей в Python */
create or replace function faculty_info(integer)
/* Функция возвращает множество записей 
	неопределенной структуры */
RETURNS setof record
as $$
SELECT educationalprogram.speciality_code AS "Код НП", 
typeofeducation.name AS "Форма обучения",
typeofeducation.trainingperiod AS "Срок обучения",
paymentmethod2educationalprogram.numberofstudents
AS "Число мест (Б)",
(SELECT pm2ep.numberofstudents 
from paymentmethod2educationalprogram AS pm2ep 
WHERE pm2ep.id_faculty=
paymentmethod2educationalprogram.id_faculty 
AND pm2ep.id_educationalprogram=
paymentmethod2educationalprogram.id_educationalprogram 
AND pm2ep.id_paymentmethod=2) AS "Число мест (К)",
q1.numberofstudents AS "Особая квота", 
q2.numberofstudents AS "Целевая квота" 
FROM paymentmethod2educationalprogram 
JOIN educationalprogram 
ON paymentmethod2educationalprogram.id_educationalprogram=
educationalprogram.id 
JOIN typeofeducation 
ON educationalprogram.id_formofeducation=typeofeducation.id 
JOIN paymentmethod 
ON paymentmethod2educationalprogram.id_paymentmethod=paymentmethod.id 
LEFT JOIN quota as q1 
ON q1.id_faculty=1 
AND q1.id_educationalprogram=educationalprogram.id 
AND q1.quotatype='Special' 
LEFT JOIN quota as q2 
ON q2.id_faculty=1 
AND q2.id_educationalprogram=educationalprogram.id 
AND q2.quotatype='Target' 
WHERE paymentmethod2educationalprogram.id_faculty=$1
AND paymentmethod2educationalprogram.id_paymentmethod=1;
$$ language SQL;

/* Попробуем ее запустить */
SELECT 'Пробуем запустить faculty_info' as Сообщение;
SELECT faculty_info(2);

/* Видно, что исчезли названия столбцов.
	Чтобы это исправить нужно задать их названия и тип данных */
SELECT 'Задаем названия и тип данных 
для столбцов при работе с record' as Сообщение;
select * from faculty_info(4) as 
("Направление подготовки" varchar(10),
"Форма обучения" varchar(50),
"Срок обучения" real,
"Число мест (Б)" smallint,
"Число мест(К)" smallint,
"Особая квота" smallint, 
"Целевая квота" smallint);
	
/* Вывести совокупность информации по коду направления подготовки 
	факультеты, форма обучения, срок обучения, числа мест 
	в зависимости от формы оплаты */
	
SELECT 'Сведения по коду НП 090301' AS Сообщение;
SELECT faculty.name as "Факультет", 
typeofeducation.name as "Форма обучения",
typeofeducation.trainingperiod as "Срок обучения", 
pm2ep1.numberofstudents as "Места (Б)", 
(select pm2ep2.numberofstudents from paymentmethod2educationalprogram 
as pm2ep2 where pm2ep2.id_faculty=
pm2ep1.id_faculty 
AND pm2ep2.id_educationalprogram=
pm2ep1.id_educationalprogram 
AND pm2ep2.id_paymentmethod=2) as "Места (К)"
from paymentmethod2educationalprogram as pm2ep1
join faculty on faculty.id=pm2ep1.id_faculty
join educationalprogram on 
pm2ep1.id_educationalprogram=educationalprogram.id
join typeofeducation on 
educationalprogram.id_formofeducation=typeofeducation.id
where educationalprogram.speciality_code='090301' and pm2ep1.id_paymentmethod=1;

/* Вывести справочную информацию по олимпиадам */
SELECT 'Справочная информация по олимпиадам' 
as Сообщение;
SELECT ol.name AS "Название олимпиады", 
bfw.bc AS "Код преимущества", 
bfw.minimumegescore AS "Минимальный балл ЕГЭ",
(SELECT count(*) FROM enrollee JOIN receivedcertificate
ON enrollee.id=receivedcertificate.id_enrollee
JOIN olympiadcertificate ON 
receivedcertificate.id_olympiadcertificate=olympiadcertificate.id
WHERE olympiadcertificate.id_olympiad=ol.id)
FROM
olympiad as ol join benefitsforthewinners as bfw on bfw.id=ol.idbenefits;

/* Какие направления подготовки соответствуют предмету ВИПС */
SELECT 'Направления подготовки, соответствующие предмету ВИПС'
AS Сообщение;
SELECT speciality.speciality_code FROM speciality 
JOIN subject 
ON speciality.subject_vips=subject.id 
WHERE subject.name LIKE '%изи%';

/* Аналитические операции */
/* Функция, выдающая таблицу из ID предметов,
	соответствующих направлению подготовки (аргумент) */
CREATE OR REPLACE FUNCTION subj_id_list(varchar(10))
RETURNS TABLE(id_subject integer)
AS $$
SELECT subject.id 
FROM subject JOIN subject2specialityege 
ON subject.id=subject2specialityege.idsubject 
WHERE subject2specialityege.speciality_code=$1;
$$ 
language SQL;

/* Пример ее использования */
SELECT 'Пример использования функции subj_id_list'
AS Сообщение;
/* Вывод всех предметов ЕГЭ, соответствующих НП 090301 */
SELECT subject.name FROM subject 
WHERE subject.id IN (SELECT subj_id_list('090301'));

/* Функция, возвращающая средний балл ЕГЭ */
create or replace function avg_ege_by_id(integer)
returns numeric 
as $$
SELECT DISTINCT (SELECT avg(pege.score) FROM passedege AS pege 
WHERE pege.id_enrollee=enrollee.id) FROM enrollee 
JOIN passedege ON enrollee.id=passedege.id_enrollee 
WHERE enrollee.id=$1;
$$
language sql;



--
--
-- Запросы с ORDER BY XXX
/* Вывести ID студентов, являющихся победителями олимпиад */
SELECT 'ID студентов победителей олимпиад' 
AS Сообщение;
SELECT DISTINCT enrollee.id 
FROM enrollee join receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
ORDER BY enrollee.id;

/* Вывести данный список в обратном порядке */
SELECT 'ID студентов победителей олимпиад (обр. порядок)' 
AS Сообщение;
SELECT DISTINCT enrollee.id 
FROM enrollee join receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
ORDER BY enrollee.id DESC;

/* Добавить столбец с информацией о числе сертификатов */
SELECT 'Добавлен столбец с информацией о числе сертификатов' 
AS Сообщение;
SELECT DISTINCT enrollee.id, enrollee.name AS "ФИО", 
/* Подзапрос в разделе выбора столбцов 
	c агрегатной функцией count */
(SELECT count(*) FROM enrollee AS enr1 
JOIN receivedcertificate ON enr1.id=receivedcertificate.id_enrollee 
WHERE enr1.id=enrollee.id) AS "Число сертификатов"   
FROM enrollee JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
ORDER BY enrollee.id;



-- Запросы с JOIN XXXXX
SELECT 'Запросы с JOIN' 
AS Сообщение;
/* Вывести количество сертификатов олимпиад
	для каждого абитуриента с ID от 70 до 80 
	сперва при помощи inner join 
	потом left outer join */
SELECT 'Вывести количество сертификатов олимпиад
	для каждого абитуриента с ID от 70 до 80 (INNER JOIN)' 
AS Сообщение;
SELECT DISTINCT enrollee.id, enrollee.name AS "ФИО", 
(SELECT count(*) FROM enrollee AS enr1 
JOIN receivedcertificate ON enr1.id=receivedcertificate.id_enrollee 
WHERE enr1.id=enrollee.id) AS "Число сертификатов"   
FROM enrollee JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
WHERE enrollee.id between 70 and 80 
ORDER BY enrollee.id;

SELECT 'Вывести количество сертификатов олимпиад
	для каждого абитуриента с ID от 70 до 80 (LEFT OUTER JOIN)' 
AS Сообщение;
SELECT DISTINCT enrollee.id, enrollee.name AS "ФИО", 
(SELECT count(*) FROM enrollee AS enr1 
JOIN receivedcertificate ON enr1.id=receivedcertificate.id_enrollee 
WHERE enr1.id=enrollee.id) AS "Число сертификатов"   
FROM enrollee LEFT JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
WHERE enrollee.id between 70 and 80 
ORDER BY enrollee.id;

SELECT 'Вывести количество сертификатов олимпиад
	для каждого абитуриента с ID от 70 до 80 (RIGHT OUTER JOIN)' 
AS Сообщение;
SELECT DISTINCT enrollee.id, enrollee.name AS "ФИО", 
(SELECT count(*) FROM enrollee AS enr1 
JOIN receivedcertificate ON enr1.id=receivedcertificate.id_enrollee 
WHERE enr1.id=enrollee.id) AS "Число сертификатов"   
FROM enrollee LEFT JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
WHERE enrollee.id between 70 and 80 
ORDER BY enrollee.id;

/* Проверка right join */
/* Определим, сколько среди абитуриентов 
	граждан каждой из добавленных в БД стран */

SELECT 'Сколько среди абитуриентов 
граждан каждой из стран (inner join)' 
AS Сообщение;
SELECT DISTINCT citizenship.name, 
(SELECT count(*) FROM enrollee2citizenship AS e2c 
WHERE e2c.id_citizenship=citizenship.id) 
FROM enrollee2citizenship 
JOIN citizenshiP 
ON citizenship.id=enrollee2citizenship.id_citizenship;

/* Чтобы определить страну, граждан которой среди
	абитуриентов нет, воспользуемся right join */
/* right join <==> right outer join */
SELECT 'Сколько среди абитуриентов 
граждан каждой из стран (right join)' 
AS Сообщение;
SELECT DISTINCT citizenship.name, 
(SELECT count(*) FROM enrollee2citizenship AS e2c 
WHERE e2c.id_citizenship=citizenship.id) FROM enrollee2citizenship 
RIGHT JOIN citizenship 
ON citizenship.id=enrollee2citizenship.id_citizenship;

/* Какие ЕГЭ нужно сдавать для поступления по определенному
	направлению подготовки */
SELECT subject.name 
FROM subject JOIN subject2specialityege 
ON subject.id=subject2specialityege.idsubject 
WHERE subject2specialityege.speciality_code='180301';

-- Запросы с агрегатными функциями XXXXX

/* Вычислить средний балл абитуриента по ЕГЭ,
	если он его сдавал, для первых 10 абитуриентов */
SELECT 'Средний балл ЕГЭ для первых десятерых' AS Сообщение;
SELECT DISTINCT enrollee.id, enrollee.name, 
get_enr_ege_stat(enrollee.id), 
(SELECT avg(pege.score) FROM passedege AS pege 
WHERE pege.id_enrollee=enrollee.id) FROM enrollee 
JOIN passedege ON enrollee.id=passedege.id_enrollee 
WHERE enrollee.id between 1 and 10;


/* Вычислить минимальный средний балл абитуриента по ЕГЭ */
SELECT 'Минимальный средний балл ЕГЭ' AS Сообщение;
SELECT min(allavgege.avgege) FROM
(SELECT 
(SELECT avg(pege.score) FROM passedege AS pege 
WHERE pege.id_enrollee=enrollee.id) as avgege FROM enrollee 
JOIN passedege ON enrollee.id=passedege.id_enrollee) as allavgege;

/* Показать абитуриентов, у которых средний балл по ЕГЭ 
	меньше 45 и указать их баллы */
SELECT 'Абитуриенты со средним баллом по ЕГЭ меньшим 45' AS Сообщение;
SELECT DISTINCT tabwithavgege.id, tabwithavgege.name, tabwithavgege.avgege, 
get_enr_ege_stat(tabwithavgege.id) FROM
(SELECT enrollee.id AS id, enrollee.name AS name,
(SELECT avg(pege.score) FROM passedege AS pege 
WHERE pege.id_enrollee=enrollee.id) as avgege FROM enrollee 
JOIN passedege ON enrollee.id=passedege.id_enrollee) as tabwithavgege
WHERE tabwithavgege.avgege<45;

/* Показать абитуриента с самым низким средним баллом по ЕГЭ */
SELECT 'Абитуриент с самым низким средним баллом по ЕГЭ' AS Сообщение;
SELECT  DISTINCT tabwithavgege.id, tabwithavgege.name, tabwithavgege.avgege FROM
(SELECT enrollee.id as id, enrollee.name as name,
(SELECT avg(pege.score) FROM passedege AS pege 
WHERE pege.id_enrollee=enrollee.id) as avgege FROM enrollee 
JOIN passedege ON enrollee.id=passedege.id_enrollee) as tabwithavgege
WHERE tabwithavgege.avgege=
(SELECT min(allavgege1.avgege1) FROM
(SELECT 
(SELECT avg(pege1.score) FROM passedege AS pege1
WHERE pege1.id_enrollee=enrollee.id) as avgege1 FROM enrollee 
JOIN passedege ON enrollee.id=passedege.id_enrollee) as allavgege1);

/* Показать абитуриентов, которые сдали больше 3 ЕГЭ */
SELECT 'Абитуриенты, которые сдали больше 3 ЕГЭ' as Сообщение;
SELECT tab_enr_npe.id, tab_enr_npe.name, tab_enr_npe.npe 
as "Число сданных ЕГЭ" 
FROM
(SELECT DISTINCT enrollee.id AS id, enrollee.name as name, 
(SELECT count(*) FROM enrollee AS enr1 
JOIN passedege AS pe1 ON enr1.id=pe1.id_enrollee 
WHERE enr1.id=enrollee.id) AS npe
FROM enrollee JOIN passedege ON enrollee.id=passedege.id_enrollee) 
AS tab_enr_npe
WHERE tab_enr_npe.npe>3;




-- Запросы с LIKE XX
SELECT 'Запросы с LIKE' 
AS Сообщение;
/* Вывести фамилию и дату рождения всех абитуриентов */
/* 	в ФИО которых содержится строка 'нар' */
SELECT 'Абитуриенты, в ФИО которых есть строка "нар"' 
AS Сообщение;
SELECT name,dob
FROM enrollee WHERE name LIKE '%нар%';

/* Вывести также гражданство таких абитуриентов */
SELECT 'Вывести также гражданство таких абитуриентов' 
AS Сообщение;
/* По умолчанию подразумевается inner join */
/* При наличии LEFT, RIGHT, FULL - outer join */
SELECT enrollee.name,enrollee.dob,citizenship.name 
FROM enrollee 
JOIN enrollee2citizenship 
ON enrollee2citizenship.id_enrollee=enrollee.id 
JOIN citizenship 
ON citizenship.id=enrollee2citizenship.id_citizenship  
WHERE enrollee.name LIKE '%нар%';

-- Прочие запросы XXX
/* Пример использования CASE и VALUES */
SELECT 'Пример использования CASE и VALUES' 
AS Сообщение;
SELECT 
(CASE WHEN column1>0 THEN 'q' ELSE '-q' END) 
FROM (VALUES (10),(-10),(20),(-20)) AS t1;

/* Получить первые 10 строк таблицы 
	при помощи LIMIT */
SELECT 'Получить первые 10 строк таблицы (LIMIT)'
AS Сообщение;
SELECT * FROM enrollee LIMIT 10;	

/* Получить первые 10 строк таблицы 
	при помощи FETCH */
SELECT 'Получить первые 10 строк таблицы (FETCH)'
AS Сообщение;
SELECT * FROM enrollee FETCH FIRST 10 ROWS ONLY;


\q

