/* Удалить БД доп. задания, если она создана */

/* Подключение к созданной базе данных */
/* Встроенная команда psql */
\c admission_office

-- Запросы из функциональных требований
\echo '\n Запросы из функциональных требований'
/* Справочные операции */
\echo '\n Запросы из ЛР №1';

/* Функция, выводящая статистику по ЕГЭ */
/* в виде двумерного массива varchar по номеру абитуриента */
CREATE OR REPLACE FUNCTION 
get_enr_ege_stat(integer) 
RETURNS varchar[] 
AS $$ 
/* :: - преобразование типов */
/* array_agg - агрегатная функция, добавляющая в массив
	все свои аргументы */
SELECT array_agg(ARRAY[left(subject.name,3)::varchar,
passedege.score::varchar]) 
FROM enrollee JOIN passedege 
ON enrollee.id=passedege.id_enrollee 
JOIN subject 
ON subject.id=passedege.id_subject 
WHERE enrollee.id=$1 
$$ LANGUAGE sql;

/* Функция, выводящая статистику по ВИПС */
/* в виде двумерного массива varchar по номеру абитуриента */
CREATE OR REPLACE FUNCTION 
get_enr_vips_stat(integer) 
RETURNS varchar[] 
AS $$ 
/* :: - преобразование типов */
/* array_agg - агрегатная функция, добавляющая в массив
	все свои аргументы */
SELECT array_agg(ARRAY[left(subject.name,3)::varchar,
passedvips.score::varchar]) 
FROM enrollee JOIN passedvips 
ON enrollee.id=passedvips.id_enrollee 
JOIN subject 
ON subject.id=passedvips.id_subject 
WHERE enrollee.id=$1 
$$ LANGUAGE sql;

/* Функция, выводящая краткую статистику по олимпиадам
	по номеру абитуриента */
CREATE OR REPLACE FUNCTION 
get_enr_olymp_stat(integer) 
RETURNS varchar[] 
AS $$ 
SELECT array_agg(array[ol.id::varchar(10),
left(subject.name,3)::varchar])
FROM enrollee 
JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
JOIN olympiadcertificate 
ON olympiadcertificate.id=
	receivedcertificate.id_olympiadcertificate 
JOIN subject 
ON subject.id=olympiadcertificate.idsubject 
JOIN olympiad AS ol
 ON olympiadcertificate.id_olympiad=ol.id
WHERE enrollee.id=$1 
$$ 
LANGUAGE sql;

/* Вывести краткую информацию об абитуриенте,
	включая гражданство, сведения о результатах ЕГЭ,
	ВИПС, олимпиадах */
\echo '\n Краткая информация об абитуриенте'

SELECT DISTINCT enrollee.id AS "ID", 
left(enrollee.name,10) AS "ФИО", 
(SELECT array_agg(left(cs.name,3)) FROM enrollee 
AS enr1 JOIN enrollee2citizenship AS e2c 
ON enr1.id=e2c.id_enrollee JOIN citizenship AS cs 
ON e2c.id_citizenship=cs.id WHERE enr1.id=enrollee.id)
AS "Гражд.",
get_enr_ege_stat(enrollee.id) AS "Рез. ЕГЭ",
get_enr_vips_stat(enrollee.id) AS "Рез. ВИПС", 
get_enr_olymp_stat(enrollee.id) AS "Рез. олимп", 
enrollee.achievementpoints AS "БИД",
enrollee.righttopriorityadmission AS "П"
FROM enrollee JOIN enrollee2citizenship 
ON enrollee.id=enrollee2citizenship.id_enrollee 
JOIN citizenship 
ON enrollee2citizenship.id_citizenship=citizenship.id 
WHERE (enrollee.id BETWEEN 35 AND 55) 
OR (enrollee.id BETWEEN 75 AND 80)
OR (enrollee.id BETWEEN 130 AND 145);	

/* Создадим функцию по выводу информации по абитуриенту. 
	Она нужна для облегчения отладки */
CREATE OR REPLACE FUNCTION show_enrollee_by_id(INTEGER)
RETURNS TABLE (id integer, 
name varchar(100), 
citizenships text[], 
egestat varchar[], 
vipsstat varchar[], 
olympstat varchar[], 
ap smallint, 
rpa boolean)
AS $$
SELECT enrollee.id AS "ID", 
enrollee.name AS "ФИО", 
(SELECT array_agg(left(cs.name,7)) FROM enrollee 
AS enr1 JOIN enrollee2citizenship AS e2c 
ON enr1.id=e2c.id_enrollee JOIN citizenship AS cs 
ON e2c.id_citizenship=cs.id WHERE enr1.id=enrollee.id),
get_enr_ege_stat(enrollee.id) AS "Рез. ЕГЭ",
get_enr_vips_stat(enrollee.id) AS "Рез. ВИПС", 
get_enr_olymp_stat(enrollee.id) AS "Рез. олимп", 
enrollee.achievementpoints AS "Б.И.Д.",
enrollee.righttopriorityadmission AS "П"
FROM enrollee JOIN enrollee2citizenship 
ON enrollee.id=enrollee2citizenship.id_enrollee 
JOIN citizenship 
ON enrollee2citizenship.id_citizenship=citizenship.id 
WHERE enrollee.id=$1;
$$
LANGUAGE SQL;

/* Протестируем ее работу */
\echo '\n Тест. show_enrollee_by_id для id=1,2,3'
SELECT Y.id,Y.name,Y.egestat,Y.ap,Y.rpa 
FROM (VALUES (1),(2),(3)) AS X, 
show_enrollee_by_id(X.column1) AS Y;

/* Вывести совокупность информации по факультету:
	доступные образовательные программы с указанием формы и срока
	обучения, специальности, доступных способов финансирования 
	с указанием числа мест и способа финансирования */
	
/* Выполним такой запрос для факультета №1 */
\echo '\n Сведения по факультету №1'
SELECT educationalprogram.speciality_code AS "Код НП", 
typeofeducation.name AS "Форма обучения",
typeofeducation.trainingperiod AS "Срок обучения",
paymentmethod2educationalprogram.numberofstudents
AS "Число мест (Б)",
(SELECT pm2ep.numberofstudents 
FROM paymentmethod2educationalprogram AS pm2ep 
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
ON paymentmethod2educationalprogram.id_paymentmethod=
	paymentmethod.id 
LEFT JOIN quota AS q1 
ON q1.id_faculty=1 
AND q1.id_educationalprogram=educationalprogram.id 
AND q1.quotatype='Special' 
LEFT JOIN quota AS q2 
ON q2.id_faculty=1 
AND q2.id_educationalprogram=educationalprogram.id 
AND q2.quotatype='Target' 
WHERE paymentmethod2educationalprogram.id_faculty=1
AND paymentmethod2educationalprogram.id_paymentmethod=1;

/* Разработаем функцию на основе данного запроса */
/* Проведем эксперимент с record - аналогом кортежей в Python */
CREATE OR REPLACE FUNCTION faculty_info(integer)
/* Функция возвращает множество записей 
	неопределенной структуры */
RETURNS setof record
AS $$
SELECT educationalprogram.speciality_code AS "Код НП", 
typeofeducation.name AS "Форма обучения",
typeofeducation.trainingperiod AS "Срок обучения",
paymentmethod2educationalprogram.numberofstudents
AS "Число мест (Б)",
(SELECT pm2ep.numberofstudents 
FROM paymentmethod2educationalprogram AS pm2ep 
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
ON paymentmethod2educationalprogram.id_paymentmethod=
	paymentmethod.id 
LEFT JOIN quota AS q1 
ON q1.id_faculty=1 
AND q1.id_educationalprogram=educationalprogram.id 
AND q1.quotatype='Special' 
LEFT JOIN quota AS q2 
ON q2.id_faculty=1 
AND q2.id_educationalprogram=educationalprogram.id 
AND q2.quotatype='Target' 
WHERE paymentmethod2educationalprogram.id_faculty=$1
AND paymentmethod2educationalprogram.id_paymentmethod=1;
$$ LANGUAGE SQL;

/* Попробуем ее запустить */
\echo '\n Пробуем запустить faculty_info для ХТФ'
SELECT faculty_info(2);

/* Видно, что исчезли названия столбцов.
	Чтобы это исправить нужно задать их названия и тип данных */
\echo '\n Задаем названия и тип данных'
\echo 'для столбцов при работе с record'
SELECT * FROM faculty_info(4) AS 
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
	
\echo '\n Сведения по коду НП 090301'
SELECT faculty.name AS "Факультет", 
typeofeducation.name AS "Форма обучения",
typeofeducation.trainingperiod AS "Срок обучения", 
pm2ep1.numberofstudents AS "Места (Б)", 
(SELECT pm2ep2.numberofstudents 
FROM paymentmethod2educationalprogram 
AS pm2ep2 WHERE pm2ep2.id_faculty=
pm2ep1.id_faculty 
AND pm2ep2.id_educationalprogram=
pm2ep1.id_educationalprogram 
AND pm2ep2.id_paymentmethod=2) AS "Места (К)"
FROM paymentmethod2educationalprogram AS pm2ep1
JOIN faculty  ON faculty.id=pm2ep1.id_faculty
JOIN educationalprogram  ON 
pm2ep1.id_educationalprogram=educationalprogram.id
JOIN typeofeducation  ON 
educationalprogram.id_formofeducation=typeofeducation.id
WHERE educationalprogram.speciality_code='090301' 
AND pm2ep1.id_paymentmethod=1;

/* Вывести справочную информацию по олимпиадам */
\echo '\n Справочная информация по олимпиадам' 
SELECT left(ol.name,7) AS "Название олимпиады", 
bfw.bc AS "Код преимущества", 
bfw.minimumegescore AS "Минимальный балл ЕГЭ",
(SELECT count(*) FROM enrollee JOIN receivedcertificate
ON enrollee.id=receivedcertificate.id_enrollee
JOIN olympiadcertificate ON 
receivedcertificate.id_olympiadcertificate=olympiadcertificate.id
WHERE olympiadcertificate.id_olympiad=ol.id)
FROM
olympiad AS ol JOIN benefitsforthewinners AS bfw 
 ON bfw.id=ol.idbenefits;

/* Какие направления подготовки соответствуют предмету ВИПС */
\echo '\n Направления подготовки, соотв. предмету ВИПС ("*изи*")'
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
LANGUAGE SQL;

/* Эксперимент с возвратом ф-ей таблицы 
	с одним атрибутом*/
\echo '\n Эксперимент с возвратом ф-ей таблицы'
SELECT subj_id_list('090301');
/* С одним атрибутом таблица возвращается нормально */

/* Проведем эксперимент с возвратом 
	таблицы из 2-х колонок*/
/* Создадим для этого какую-нибудь функцию */
CREATE OR REPLACE FUNCTION subj_id_list2(varchar(10))
RETURNS TABLE(id_subject integer, random integer)
AS $$
SELECT subject.id, 5
FROM subject JOIN subject2specialityege 
ON subject.id=subject2specialityege.idsubject 
WHERE subject2specialityege.speciality_code=$1;
$$ 
LANGUAGE SQL;

\echo '\n Эксперимент с возвратом ф-ей таблицы с 2-мя атрибутами'
SELECT subj_id_list2('090301');
/* Возвращается таблица с одним атрибутом, значения
	которого - записи */

/* Чтобы исправить данную ошибку, перенесем вызов ф-и
	в раздел FROM */
\echo '\nПереносим вызов ф-и в раздел FROM и все работает нормально'
SELECT id_subject, random FROM subj_id_list2('090301');

/* Удалим ф-ю subj_id_list2 */
DROP FUNCTION subj_id_list2(varchar(10));

/* Пример ее использования */
\echo '\n Пример использования функции subj_id_list'
/* Вывод всех предметов ЕГЭ, соответствующих НП 090301 */
SELECT subject.name FROM subject 
WHERE subject.id IN (SELECT subj_id_list('090301'));

/* Функция, возвращающая средний балл ЕГЭ */
CREATE OR REPLACE function avg_ege_by_id(integer)
RETURNS numeric 
AS $$
SELECT DISTINCT (SELECT avg(pege.score) FROM passedege AS pege 
WHERE pege.id_enrollee=enrollee.id) FROM enrollee 
JOIN passedege ON enrollee.id=passedege.id_enrollee 
WHERE enrollee.id=$1;
$$
LANGUAGE sql;

/* Функция проверяющая, является ли абитуриент с
	ID $1 победителем олимпиады 2 типа, необходимой 
	для поступления	на НП $2. 
	При этом проводится проверка минимального балла 
	ЕГЕ 
	Функция возвращает 0, поступление по олимпиаде 2 типа
	невозможно и число>0, если возможно. 
	*/
CREATE OR REPLACE function check_olymp_t2(integer,varchar(10))
RETURNS bigint
AS $$
SELECT count(*) FROM enrollee AS enr 
JOIN receivedcertificate AS rc 
 ON enr.id=rc.id_enrollee 
JOIN olympiadcertificate AS oc 
 ON rc.id_olympiadcertificate=oc.id
JOIN olympiadcertificate2speciality AS oc2s 
 ON oc2s.id_olympiadcertificate=oc.id 
JOIN olympiad  ON olympiad.id=oc.id_olympiad 
JOIN benefitsforthewinners AS bftw 
 ON bftw.id=olympiad.idbenefits 
WHERE oc2s.speciality_code=$2 
AND enr.id=$1 AND 
(SELECT ege_by_enr_subj(enr.id,oc.idsubject))>bftw.minimumegescore;
$$
LANGUAGE sql;

/* Функция определяет, является ли абитуриент победителем
	олимпиады типа 1 
	если не является - 0,
	если является > 0 */
CREATE OR REPLACE function check_olymp_t1(integer)
RETURNS bigint
AS $$
SELECT count(*) FROM enrollee AS enr 
JOIN receivedcertificate AS rc  ON enr.id=rc.id_enrollee 
JOIN olympiadcertificate AS oc  ON rc.id_olympiadcertificate=oc.id
JOIN olympiad AS ol  ON ol.id=oc.id_olympiad
WHERE ol.idbenefits=1 AND enr.id=$1;
$$
LANGUAGE sql;

/* Функция, которая определяет балл ЕГЭ
по предмету олимпиады */
CREATE OR REPLACE function 
ege_by_enr_subj(enr_id integer,subj_id integer)
RETURNS smallint 
AS $$
SELECT pe.score FROM
enrollee AS enr JOIN passedege AS pe
 ON enr.id=pe.id_enrollee
WHERE enr.id=enr_id AND pe.id_subject=subj_id;
$$
LANGUAGE sql;

CREATE OR REPLACE FUNCTION subj_id_list(varchar(10))
RETURNS TABLE(id_subject integer)
AS $$
SELECT subject.id 
FROM subject JOIN subject2specialityege 
ON subject.id=subject2specialityege.idsubject 
WHERE subject2specialityege.speciality_code=$1;
$$ 
LANGUAGE SQL;


/* Функция проверяет, сдал ли абитуриент необходимые ЕГЭ */
CREATE OR REPLACE function 
check_list_subj(enr_id integer, spec varchar(10))
RETURNS integer
AS $$
SELECT
(case when 
(SELECT count(*) FROM enrollee AS enr 
JOIN passedege AS pe 
 ON enr.id=pe.id_enrollee
WHERE enr.id=enr_id and
pe.id_subject in
(SELECT subj_id_list(spec)))
=(SELECT count(*) FROM (SELECT subj_id_list(spec)) AS subj_list)
then 1
else 0
end);
$$
LANGUAGE sql;

/* Функция для вычисления конкурсного балла */
CREATE OR REPLACE function
count_conc_score(enr_id integer, spec varchar(10))
RETURNS bigint
AS $$

/* Сумма баллов за ЕГЭ по требуемым предметам,
	если нужные сданы */
	
/* Функция coalesce возвращает аргумент2, если аргумент 1 - NULL 
	иначе возвращает аргумент 1*/
SELECT coalesce(sum1.score,0)*check_list_subj(enr_id,spec)+
1000*(check_olymp_t1(enr_id)+check_olymp_t2(enr_id,spec))

/* Баллы за инд. достижения */
+(SELECT enr2.achievementpoints 
FROM enrollee AS enr2 WHERE enr2.id=enr_id) 

/* Баллы за ВИПС по предмету,
	связанному со специальностью */
+
coalesce((SELECT sum(pv.score) FROM enrollee AS enr2 
JOIN passedvips AS pv 
 ON enr2.id=pv.id_enrollee
WHERE enr2.id=enr_id and
pv.id_subject=
(SELECT subject_vips FROM speciality 
WHERE speciality.speciality_code=spec)
),0)

FROM
/* Вычисление суммы баллов ЕГЭ по треб. предметам */
(SELECT sum(pe.score) AS score FROM enrollee AS enr 
JOIN passedege AS pe 
 ON enr.id=pe.id_enrollee
WHERE enr.id=enr_id and
pe.id_subject in
(SELECT subj_id_list(spec))) AS sum1
$$
LANGUAGE sql;

/* Однако еще существует т.н. право на приоритетное зачисление
	оно реализуется следующим образом: если у 2-х абитуриентов 
	равные баллы и проходит только 1, то проходит тот, 
	у кого есть преимущественное право на зачисление
	
	Это реализуется так: сортировка абитуриентов при составлении
	рейтинга будет осуществляться не по конкурсному баллу, а по
	итоговому, формируемому путем умножения конкурсного на 2 
	и добавления к этому значению 1 для тех, у кого есть
	преимущественное право на зачисление,
	а отображаться будет конкурсный балл
*/
	
CREATE OR REPLACE function
count_final_score(enr_id integer, spec varchar(10))
RETURNS bigint
AS $$
SELECT count_conc_score(enr_id, spec)*2+
(case 
	when 
	(SELECT enr.righttopriorityadmission 
	FROM enrollee AS enr WHERE enr.id=enr_id) IS true then 1 
	else 0 
end)
$$
LANGUAGE sql;


/* Ф-я выдает рейтинг, поступающих
	на образовательную программу определенного факультета
	с учетом формы оплаты и квоты */
CREATE OR REPLACE function
get_enr_rating (fac_id integer,
	pm_id integer,
	q_id integer, /* 0 воспр. NULL */
	sc varchar(10),
	fe integer)
RETURNS TABLE (
	id integer,
	name varchar(100),
	egestat varchar[],
	vipsstat varchar[],
	olympstat varchar[],
	ap smallint,
	rpa boolean,
	cs bigint,
	fs bigint,
	ec boolean
)
AS $$
SELECT 
	enr.id, enr.name, 
	get_enr_ege_stat(enr.id), 
	get_enr_vips_stat(enr.id),
	get_enr_olymp_stat(enr.id),
	enr.achievementpoints,
	enr.righttopriorityadmission,
	count_conc_score(enr.id,sc) AS cs,
	count_final_score(enr.id,sc) AS fs,
	appl.enrolmentconsent AS ec
	
FROM enrollee AS enr 
JOIN application AS appl
 ON enr.id=appl.id_enrollee
JOIN educationalprogram AS ep
 ON ep.id=appl.id_educationalprogram

WHERE appl.id_faculty=fac_id
AND appl.id_paymentmethod=pm_id
AND appl.id_quota IS NOT DISTINCT FROM 
(case when q_id=0 then NULL else q_id end)
AND ep.speciality_code=sc
AND ep.id_formofeducation=fe
ORDER BY fs desc;
$$
LANGUAGE sql;

/* Ф-я выдает список поступающих, реком. к зачислению
	на образовательную программу определенного факультета
	с учетом формы оплаты и квоты */
CREATE OR REPLACE function
get_enr_adm_list (fac_id integer,
	pm_id integer,
	q_id integer, /* 0 воспр. NULL */
	sc varchar(10),
	fe integer)
RETURNS TABLE (
	id_final bigint,
	id integer,
	name varchar(100),
	egestat varchar[],
	vipsstat varchar[],
	olympstat varchar[],
	ap smallint,
	rpa boolean,
	cs bigint,
	fs bigint,
	ec boolean,
	egeresult bigint
)
AS $$
SELECT Q.*, 
(SELECT sum(pe.score) AS score FROM enrollee AS enr2 
JOIN passedege AS pe 
 ON enr2.id=pe.id_enrollee
WHERE enr2.id=Q.id and
pe.id_subject in
(SELECT subj_id_list(sc))) AS egeresult
FROM
/* Добавляем к рейтингу абитуриентов новый порядковый номер */
(SELECT (row_number() over (ORDER BY fs desc)) AS id_final, id,
name, egestat, vipsstat, olympstat,	ap, rpa, cs, fs, ec
FROM get_enr_rating(fac_id,pm_id,q_id,sc,fe)) AS Q 
/* Ограничения по количеству мест и согласию на зачисление */
WHERE Q.id_final<=
	(SELECT 
	pm2ep.numberofstudents 
	FROM paymentmethod2educationalprogram AS pm2ep
	JOIN educationalprogram AS ep on
	pm2ep.id_educationalprogram=ep.id
	WHERE ep.speciality_code=sc 
	AND ep.id_formofeducation=fe
	AND pm2ep.id_paymentmethod=pm_id
	)
	AND Q.ec;
$$
LANGUAGE sql;

/* Функция, вычисляющая средний балл среди зачисленных
	на образовательную программу определенного факультета
	с учетом формы оплаты и квоты */
CREATE OR REPLACE function
get_enr_adm_list_avg_ege (fac_id integer,
	pm_id integer,
	q_id integer, 
	sc varchar(10),
	fe integer)
RETURNS numeric
AS $$
SELECT avg(Q.egeresult) FROM
(SELECT egeresult FROM
get_enr_adm_list(fac_id,pm_id,q_id,sc,fe)
WHERE egeresult IS DISTINCT FROM NULL
) AS Q;
$$
LANGUAGE SQL;

/* Функция, вычисляющая проходной балл ЕГЭ среди зачисленных
	на образовательную программу определенного факультета
	с учетом формы оплаты и квоты */
CREATE OR REPLACE function
get_enr_adm_list_min_ege (fac_id integer,
	pm_id integer,
	q_id integer, 
	sc varchar(10),
	fe integer)
RETURNS bigint
AS $$
SELECT min(Q.egeresult) FROM
(SELECT egeresult FROM
get_enr_adm_list(fac_id,pm_id,q_id,sc,fe)
WHERE egeresult IS DISTINCT FROM NULL
) AS Q;
$$
LANGUAGE SQL;

/* Запросы для отладки */
/* Выведем инф-ю по абитуриентам 10,76,77,136
*/

\echo '\n Инф-я по абитуриентам 10, 76, 77, 136'

SELECT Y.id,Y.name AS "ФИО",
Y.egestat AS "ЕГЭ",Y.ap AS "Б.И.Д.",Y.rpa AS "П" 
FROM (VALUES (10),(76),(77),(136)) AS X, 
show_enrollee_by_id(X.column1) AS Y;
	
/* Проверим работу функции check_olymp_t1 */
\echo '\n Проверка ф-ии check_olymp_t1 для абит. 136'
SELECT check_olymp_t1(136);

/* Проверка функции check_list_subj */
\echo 'Проверка ф-ии check_list_subj для абит. 2'
SELECT check_list_subj(2,'090301');
\echo 'Проверка ф-ии check_list_subj для абит. 72'
SELECT check_list_subj(72,'090301');

/* Проверка функции count_count_conc_score */
\echo 'Проверка ф-ии count_conc_score' 
\echo 'для абит. 10 (090301,180301), 76, 77'
SELECT count_conc_score(10,'090301');
SELECT count_conc_score(10,'180301');
SELECT count_conc_score(76,'090301');
SELECT count_conc_score(77,'090301');
/* Проверка вычисления конкурсного балла
	Для случая, когда абитуриент является победителем 
	олимпиад, дающих привелегии типов 1 и 2 */
\echo '\n Информация по олимпиадам абитуриента 137'
SELECT get_enr_olymp_stat(137);
SELECT check_olymp_t1(137);
\echo '\n Проверка ф-ии count_conc_score' 
\echo 'для абит. 137 (090301,180301)'
SELECT count_conc_score(137,'090301');
SELECT count_conc_score(137,'180301');

/* Проверка вычисления итогового балла для абитуриентов 10, 76
	при поступлении на направление 090301 */
\echo '\n Вычисление итогового балла для абит. 10, 76'
SELECT count_final_score(10,'090301');
SELECT count_final_score(76,'090301');

/* Поступление на какие специальности возможно
	для победителей соответствующих олимпиад 
	с привелегиями 2 типа */
\echo '\n Связь специальностей и сертификатов победителей олимпиад'
SELECT oc.id AS "ID серт",oc.id_olympiad AS "ID Олимп", 
oc2s.speciality_code FROM olympiadcertificate2speciality AS oc2s 
JOIN olympiadcertificate AS oc  ON 
oc.id=oc2s.id_olympiadcertificate;

SELECT 'Добавление специальности 090301 для серт. 1 и 2'
AS Сообщение;
/* Добавим для возможность использования сертификатов 1 и 2 
	для поступления на специальность 090301 */
INSERT INTO olympiadcertificate2speciality
VALUES(1,'090301');
INSERT INTO olympiadcertificate2speciality
VALUES(2,'090301');

/* Проверим работу функции count_conc_score вновь 
	результат должен различаться более чем на 1000 
	ведь одна из олимпиад не зависит от специальности, 
	а другая зависит 
	*/
\echo '\n Повторная проверка count_conc_score'
\echo 'для абит. 10 (090301,180301), 76, 77'
SELECT count_conc_score(137,'090301');
SELECT count_conc_score(137,'180301');

/* Удалим добавленные выше записи из таблицы
	olympiadcertificate2speciality */
\echo '\n Удаление добавленных выше записей из'
\echo 'olympiadcertificate2speciality'
delete FROM olympiadcertificate2speciality WHERE
id_olympiadcertificate<=2 AND speciality_code='090301';

/* Куда были поданы заявления:
	факультет, ф. опл., квота, обр. программа */
\echo '\n Куда были поданы заявления?'
SELECT DISTINCT ap1.id_faculty,ap1.id_quota, 
ap1.id_educationalprogram, ap1.id_paymentmethod,
(SELECT count(*) FROM application AS ap2  
WHERE ap2.id_faculty=ap1.id_faculty and
ap2.id_quota IS NOT DISTINCT FROM ap1.id_quota and
ap2.id_educationalprogram=ap1.id_educationalprogram
AND ap2.id_paymentmethod=ap1.id_paymentmethod
) AS quantity
FROM application AS ap1;

/* Изменим предыдущий запрос так, 
чтобы вывод был более понятный */

\echo '\n Вывод пред запроса в более понятной форме' 
SELECT DISTINCT 
fac.id AS "ID Фак",
fac.name AS "Факультет",
ep.id_formofeducation AS "Форма обуч.",
ap1.id_quota AS "Квота", 
ep.speciality_code AS "Направление",
pm.paymentmethodtype AS "Способ оплаты", 
(SELECT count(*) FROM application AS ap2  
WHERE ap2.id_faculty=ap1.id_faculty and
/* Со значениями NULL обычные операторы для сравнения
	не работают */
ap2.id_quota IS NOT DISTINCT FROM ap1.id_quota and
ap2.id_educationalprogram=ap1.id_educationalprogram
AND ap2.id_paymentmethod=ap1.id_paymentmethod) AS quantity
FROM application AS ap1
JOIN educationalprogram AS ep
 ON ap1.id_educationalprogram=ep.id
JOIN faculty  AS fac 
 ON fac.id=ap1.id_faculty
JOIN paymentmethod AS pm 
 ON pm.id=ap1.id_paymentmethod;

/* Пусть абитуриенты из группы 1 Плана Генерации
	Данных поступают на места, финансируемые
	из средств федерального бюджета */
\echo '\n Пусть абит-ы из гр. 1 Плана Ген-и пост. на бюдж. места'
UPDATE application SET id_paymentmethod=1
WHERE id BETWEEN 1 AND 40;

/* Посмотрим, что изменилось в распределении заявлений */
\echo '\n Посмотрим, что изм. в распред. заявл.'
SELECT DISTINCT fac.name AS "Факультет",
fac.id AS "ID Фак",
ep.id_formofeducation AS "Форма обуч.",
ap1.id_quota AS "Квота", 
ep.speciality_code AS "Направление",
pm.paymentmethodtype AS "Способ оплаты", 
(SELECT count(*) FROM application AS ap2  
WHERE ap2.id_faculty=ap1.id_faculty and
/* Со значениями NULL обычные операторы для сравнения
	не работают */
ap2.id_quota IS NOT DISTINCT FROM ap1.id_quota and
ap2.id_educationalprogram=ap1.id_educationalprogram
AND ap2.id_paymentmethod=ap1.id_paymentmethod) AS quantity
FROM application AS ap1
JOIN educationalprogram AS ep
 ON ap1.id_educationalprogram=ep.id
JOIN faculty  AS fac 
 ON fac.id=ap1.id_faculty
JOIN paymentmethod AS pm 
 ON pm.id=ap1.id_paymentmethod;

/* Какие абитуриенты подали заявление 
на поступление в рамках квоты */
\echo '\n Проверим, никто ли не поступает в рамках квот?'
SELECT enr.id,enr.name,appl.id_faculty FROM
enrollee AS enr JOIN application AS appl
 ON enr.id=appl.id_enrollee
WHERE appl.id_quota IS DISTINCT FROM NULL;
/* Абитуриенты не найдены */


/* Проверим работу ф-и, выводящей рейтинг абитуриентов */
\echo '\n Рейтинг ФПИК, бюджет, ОЗ, общ. осн., 090301'
SELECT row_number() over (ORDER BY fs desc) AS "№ в рейт.",
id, left(name,10) AS "ФИО",egestat AS "ЕГЭ",ap AS "Б.И.Д.",
rpa AS "Приор.",cs AS "К.Б.",fs AS "И. Б."
FROM get_enr_rating(5,1,0,'090301',2);

\echo '\n Рейтинг ФПИК, контракт, ОЗ, общ. осн., 090301'
SELECT row_number() over (ORDER BY fs desc) AS "№ в рейт.",
id, left(name,10) AS "ФИО",vipsstat AS "В.И.П.С.",ap AS "Б.И.Д.",
rpa AS "Приор.",cs AS "К.Б.",fs AS "И. Б."
FROM get_enr_rating(5,2,0,'090301',2);

\echo '\n Рейтинг ХТФ, контракт, О, общ. осн., 180301'
SELECT row_number() over (ORDER BY fs desc) AS "№ в рейт.",
id, left(name,10) AS "ФИО",vipsstat AS "В.И.П.С.",ap AS "Б.И.Д.",
rpa AS "Приор.",cs AS "К.Б.",fs AS "И. Б."
FROM get_enr_rating(2,2,0,'180301',1);

\echo '\n Рейтинг ФЭВТ, бюджет, О, общ. осн., 090304'
SELECT row_number() over (ORDER BY fs desc) AS "№ в рейт.",
id, left(name,10) AS "ФИО",egestat AS "ЕГЭ",
olympstat AS "Олимп",
ap AS "Б.И.Д.",
rpa AS "Приор.",cs AS "К.Б.",fs AS "И. Б."
FROM get_enr_rating(1,1,0,'090304',1);

/* Проверим работу ф-и, выводящей список лиц, рекомендованных 
к зачислению */

/* Поскольку зачислению подлежат лишь лица, давшие согласие
	зачисление, то в целях тестирования пусть факт  согласия
	будет установлен для всех заявлений, хотя по закону 
	абитуриент может заявить о согласии на зачислении лишь по 1 
	заявлению */
\echo '\n В целях тестирования установим значение атрибута'
\echo 'enrolmentconsent=true для всех экз. сущности application'
UPDATE application SET enrolmentconsent=true;
/* Проверим, остались заявления без согласия на зачисление */
\echo 'Проверим, остались ли заявления'
\echo 'без согласия на зачисление'
SELECT count(*) FROM application WHERE
enrolmentconsent=false;

\echo '\n Список лиц, рекомендованных к зачислению'
\echo 'ФЭВТ, бюджет, О, общ. осн., 090304'
SELECT id_final AS "№",
id, left(name,10) AS "ФИО",egestat AS "ЕГЭ", 
egeresult AS "Балл ЕГЭ",
olympstat AS "Олимп",
ap AS "БИД",
rpa AS "Пр.",cs AS "КБ",fs AS "ИБ"
FROM get_enr_adm_list(1,1,0,'090304',1);

\echo '\n Список лиц, рекомендованных к зачислению'
\echo 'ФПИК, бюджет, О-З, общ. осн., 090301'
SELECT id_final AS "№ в рейт.",
id, left(name,10) AS "ФИО",egestat AS "ЕГЭ", 
egeresult AS "Балл ЕГЭ",
ap AS "Б.И.Д.",
rpa AS "Приор.",cs AS "К.Б.",fs AS "И. Б."
FROM get_enr_adm_list(5,1,0,'090301',2);

/* Проверка работы ф-и, вычисляющей средний балл
	среди зачисленных */
\echo '\n Средний балл, среди зачисленных на'
\echo 'ФЭВТ, бюджет, О, общ. осн., 090304'
SELECT get_enr_adm_list_avg_ege(1,1,0,'090304',1);

\echo '\n Средний балл, среди зачисленных на'
\echo 'ФПИК, бюджет, ОЗ, общ. осн., 090301'
SELECT get_enr_adm_list_avg_ege(5,1,0,'090301',2);

\echo '\n Средний балл, среди зачисленных на'
\echo 'ФПИК, контракт, ОЗ, общ. осн., 090301'
SELECT get_enr_adm_list_avg_ege(5,2,0,'090301',2);

\echo '\n Средний балл, среди зачисленных на'
\echo 'ХТФ, контракт, ОЗ, общ. осн., 180301'
SELECT get_enr_adm_list_avg_ege(2,1,0,'180301',2);

-- Транзакционные операции
\echo '\n Транзакционные операции из функциональных требований'
/* Добавим на химфак 1 абитуриента, поступающего через ЕГЭ */
\echo '\n Средний балл вычислить нельзя, потому что'
\echo 'все абитуриенты поступали через ВИПС'
\echo 'Добавим 1 абитуриента, поступавшего через ЕГЭ'
/* Регистрация абитуриента */
INSERT INTO enrollee VALUES 
	(default,
	'Иван Петров', -- ФИО
	'01.01.1988', -- Дата рождения
	'At11', -- Документ об образовании
	0, -- Б. И. Д.
	false, -- Право на особую квоту
	false, -- Договор о целевом обучении
	false, -- Приор. зачисление
	false, -- Огр. возможности
	false); -- Соотечественник за рубежом
	
/* Проверим, что он добавлен */
\echo '\n Проверим, что новый абитуриент добавлен'
SELECT id, name FROM enrollee WHERE name='Иван Петров';

/* Регистрация заявления абитуриента */
INSERT INTO application VALUES
	(default,
	2, -- ID факультета
	2, -- ID метода оплаты
	NULL, -- На общих основаниях
	4, -- ID образовательной программы
	146, -- ID абитуриента
	true);

\echo 'Убедимся, что запись в application добавлена'
SELECT id FROM application WHERE id_enrollee=146;

/* Регистрация результатов сдачи ЕГЭ */
INSERT INTO passedege VALUES
	(default,
	146,
	3,
	date '01.06.2020',
	90);
INSERT INTO passedege VALUES
	(default,
	146,
	1,
	date '02.06.2020',
	90);
INSERT INTO passedege VALUES
	(default,
	146,
	5,
	date '03.06.2020',
	90);

-- Аналитические операции (продолжение)
\echo '\n Продолжение аналитических операций'

\echo 'Убедимся, что запись в passedege добавлена'
SELECT id FROM passedege WHERE id_enrollee=146;

/* Вновь вычислим средний балл */
\echo '\n Средний балл, среди зачисленных на'
\echo 'ХТФ, контракт, ОЗ, общ. осн., 180301'
\echo 'с одним добавленным абитуриентом,'
\echo 'поступившем через ЕГЭ'
SELECT get_enr_adm_list_avg_ege(2,2,0,'180301',1);

/* Удалим этого абитуриента */
\echo 'Удаляем этого абитуриента'
delete FROM enrollee WHERE name='Иван Петров';
/* При этом автоинкрементальный атрибут ID 
	автоматически не уменьшается.
	Уменьшим его вручную */
\echo 'Уст. для счетчика атр. id сущности enrollee значение 145'
SELECT setval('enrollee_id_seq',145);

\echo '\n Убедимся, что запись в application'
\echo 'удалилась автоматически'
\echo 'благодаря  ON delete cascade' 
\echo 'для внешнего ключа id_enrollee'
SELECT id FROM application WHERE id_enrollee=146;
\echo 'Уст. для счетчика атр. id сущности application значения 150'
SELECT setval('application_id_seq',150);

\echo 'Убедимся, что запись из passedege удалилась автоматически'
SELECT id FROM passedege WHERE id_enrollee=146;
\echo 'Уст. для счетчика атр. id сущности passedege значения 40'
SELECT setval('passedege_id_seq',335);



/* Специально уменьшим число мест 
	на ФЭВТ, 090304, 
	чтобы проверить,
	как вычисляется средний балл */
\echo '\n Уменьшим число мест ФЭВТ по напр. 090304 до 2-х'
\echo 'чтобы проверить как вычисляется средний балл'
UPDATE paymentmethod2educationalprogram
SET numberofstudents=2 
WHERE id=3;

\echo '\n Список рекомендованных к зачислению'
\echo 'по направлению 090304'	
\echo 'на бюджетные места при числе мест 2'
SELECT id_final AS "№ в рейт.",
id, left(name,10) AS "ФИО",egestat AS "ЕГЭ", egeresult AS "Б. ЕГЭ",
olympstat AS "Ол.",
ap AS "ИД",
rpa AS "П",cs AS "КБ",fs AS "ИБ"
FROM get_enr_adm_list(1,1,0,'090304',1);

\echo '\n Средний балл, среди зачисленных на'
\echo 'Рейтинг ФПИК, бюджет, ОЗ, общ. осн., 090301'
\echo 'При числе мест 2 человека'
SELECT get_enr_adm_list_avg_ege(1,1,0,'090304',1);

/* Вернем прежнее количество мест */
\echo '\n Восстановим прежнее количество мест'
UPDATE paymentmethod2educationalprogram
SET numberofstudents=40 
WHERE id=3;

/* План зачисления абитуриентов (общие основания) */
\echo '\n План зачисления абитуриентов (общ. основания)'
SELECT 
	br.name AS "Филиал",
	f.name AS "Ф-т",
	ep.speciality_code AS "Код НП",
	toe.name AS "Форма об.",
	pm.paymentmethodtype AS "Оплата",
	pm2ep.numberofstudents AS "Места",
	(SELECT count(*) FROM application AS ap  
		WHERE 
		ap.id_faculty=f.id and
		/* Со значениями NULL обычные операторы для сравнения
		не работают */
		ap.id_quota IS NOT DISTINCT FROM NULL and
		ap.id_educationalprogram=ep.id
		AND ap.id_paymentmethod=pm.id
	) AS "Заявления"
FROM 
	branch AS br
	JOIN faculty AS f
	 ON br.id=f.id_branch
	JOIN paymentmethod2educationalprogram AS pm2ep
	 ON pm2ep.id_faculty=f.id
	JOIN educationalprogram AS ep
	 ON pm2ep.id_educationalprogram=ep.id
	JOIN typeofeducation AS toe
	 ON toe.id=ep.id_formofeducation
	JOIN paymentmethod AS pm on
	pm2ep.id_paymentmethod=pm.id;

/* Определение наличия недобора абитуриентов */
\echo '\n Определение направлений с недобором';
SELECT Q.* 
FROM
(SELECT 
	br.name AS "Филиал",
	f.name AS "Ф-т",
	ep.speciality_code AS "Код НП",
	toe.name AS "Форма об.",
	pm.paymentmethodtype AS "Оплата",
	pm2ep.numberofstudents AS "Места",
	(SELECT count(*) FROM application AS ap  
		WHERE 
		ap.id_faculty=f.id and
		/* Со значениями NULL обычные операторы для сравнения
		не работают */
		ap.id_quota IS NOT DISTINCT FROM NULL and
		ap.id_educationalprogram=ep.id
		AND ap.id_paymentmethod=pm.id
	) AS "Заявления"
	
FROM 
	branch AS br
	JOIN faculty AS f
	 ON br.id=f.id_branch
	JOIN paymentmethod2educationalprogram AS pm2ep
	 ON pm2ep.id_faculty=f.id
	JOIN educationalprogram AS ep
	 ON pm2ep.id_educationalprogram=ep.id
	JOIN typeofeducation AS toe
	 ON toe.id=ep.id_formofeducation
	JOIN paymentmethod AS pm on
	pm2ep.id_paymentmethod=pm.id) AS Q
WHERE Q."Места">Q."Заявления";

-- Update
\echo '\n Запросы с update'
\echo '\n Уменьшим значение минимального балла ЕГЭ'
\echo 'для олимпиад 2-го типа'
UPDATE benefitsforthewinners SET minimumegescore=40 WHERE id=2;
SELECT * FROM benefitsforthewinners;

-- Запросы с ORDER BY
\echo '\n Запросы с ORDER BY'
/* Вывести ID студентов, являющихся победителями олимпиад */
\echo '\n ID студентов победителей олимпиад' 
SELECT DISTINCT enrollee.id 
FROM enrollee JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
ORDER BY enrollee.id;

/* Вывести данный список в обратном порядке */
\echo '\n ID студентов победителей олимпиад (обр. порядок)' 
SELECT DISTINCT enrollee.id 
FROM enrollee JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
ORDER BY enrollee.id DESC;

/* Добавить столбец с информацией о числе сертификатов */
\echo '\n Добавлен столбец с информацией о числе сертификатов' 
SELECT DISTINCT enrollee.id, enrollee.name AS "ФИО", 
/* Подзапрос в разделе выбора столбцов 
	c агрегатной функцией count */
(SELECT count(*) FROM enrollee AS enr1 
JOIN receivedcertificate 
ON enr1.id=receivedcertificate.id_enrollee 
WHERE enr1.id=enrollee.id) AS "Число сертификатов"   
FROM enrollee JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
ORDER BY enrollee.id;

/* Запрос с ORDER BY и датами */
/* Вывести список всех абитуриентов старше 25 лет 
	и упорядочить их в порядке убывания возраста */
/* Ф-я age возвращает тип данных интервал
	ф-я date_part возвращает число, выделяемое из интервала
	current_timestamp - текущее время (timestamp) */
\echo '\n Абитуриенты, которые старше 25 лет'
SELECT id,name,dob,
(SELECT 
date_part('year',
age(current_timestamp, enrollee.dob::timestamp))) 
AS AgeInYears 
FROM enrollee 
WHERE 
(SELECT 
date_part('year',
age(current_timestamp, enrollee.dob::timestamp)))
>25 ORDER BY AgeInYears DESC;

-- Запросы с JOIN
\echo '\n Запросы с JOIN' 
/* Вывести количество сертификатов олимпиад
	для каждого абитуриента с ID от 70 до 80 
	сперва при помощи inner JOIN 
	потом left outer JOIN */
\echo '\n Вывести количество сертификатов олимпиад'
\echo 'для каждого абитуриента с ID от 70 до 80 (INNER JOIN)' 
SELECT DISTINCT enrollee.id, enrollee.name AS "ФИО", 
(SELECT count(*) FROM enrollee AS enr1 
JOIN receivedcertificate 
ON enr1.id=receivedcertificate.id_enrollee 
WHERE enr1.id=enrollee.id) AS "Число сертификатов"   
FROM enrollee JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
WHERE enrollee.id BETWEEN 70 AND 80 
ORDER BY enrollee.id;

\echo '\n Вывести количество сертификатов олимпиад'
\echo 'для каждого абитуриента с ID от 70 до 80 (LEFT OUTER JOIN)' 
SELECT DISTINCT enrollee.id, enrollee.name AS "ФИО", 
(SELECT count(*) FROM enrollee AS enr1 
JOIN receivedcertificate 
ON enr1.id=receivedcertificate.id_enrollee 
WHERE enr1.id=enrollee.id) AS "Число сертификатов"   
FROM enrollee LEFT JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
WHERE enrollee.id BETWEEN 70 AND 80 
ORDER BY enrollee.id;

\echo '\n Вывести количество сертификатов олимпиад'
\echo 'для каждого абитуриента с ID от 70 до 80 (RIGHT OUTER JOIN)' 
SELECT DISTINCT enrollee.id, enrollee.name AS "ФИО", 
(SELECT count(*) FROM enrollee AS enr1 
JOIN receivedcertificate 
ON enr1.id=receivedcertificate.id_enrollee 
WHERE enr1.id=enrollee.id) AS "Число сертификатов"   
FROM enrollee LEFT JOIN receivedcertificate 
ON enrollee.id=receivedcertificate.id_enrollee 
WHERE enrollee.id BETWEEN 70 AND 80 
ORDER BY enrollee.id;

/* Проверка right JOIN */
/* Определим, сколько среди абитуриентов 
	граждан каждой из добавленных в БД стран */

\echo '\n Сколько среди абитуриентов'
\echo 'граждан каждой из стран (inner JOIN)' 
SELECT DISTINCT citizenship.name, 
(SELECT count(*) FROM enrollee2citizenship AS e2c 
WHERE e2c.id_citizenship=citizenship.id) 
FROM enrollee2citizenship 
JOIN citizenshiP 
ON citizenship.id=enrollee2citizenship.id_citizenship;

/* Чтобы определить страну, граждан которой среди
	абитуриентов нет, воспользуемся right JOIN */
/* right JOIN <==> right outer JOIN */
\echo '\n Сколько среди абитуриентов'
\echo 'граждан каждой из стран (right JOIN)' 
SELECT DISTINCT citizenship.name, 
(SELECT count(*) FROM enrollee2citizenship AS e2c 
WHERE e2c.id_citizenship=citizenship.id) 
FROM enrollee2citizenship 
RIGHT JOIN citizenship 
ON citizenship.id=enrollee2citizenship.id_citizenship;

/* Какие ЕГЭ нужно сдавать для поступления по определенному
	направлению подготовки */
\echo '\n Какие ЕГЭ нужно сдавать для поступления по опр.'
\echo 'напр. подготовки'
SELECT subject.name 
FROM subject JOIN subject2specialityege 
ON subject.id=subject2specialityege.idsubject 
WHERE subject2specialityege.speciality_code='180301';

-- Запросы с агрегатными функциями
\echo '\n Запросы с агрегатными функциями'

/* Вычислить средний балл абитуриента по ЕГЭ,
	если он его сдавал, для первых 10 абитуриентов */
\echo '\nСредний балл ЕГЭ для первых десятерых'
SELECT DISTINCT enrollee.id, enrollee.name, 
get_enr_ege_stat(enrollee.id), 
(SELECT avg(pege.score) FROM passedege AS pege 
WHERE pege.id_enrollee=enrollee.id) FROM enrollee 
JOIN passedege ON enrollee.id=passedege.id_enrollee 
WHERE enrollee.id BETWEEN 1 AND 10;


/* Вычислить минимальный средний балл абитуриента по ЕГЭ */
/* Сообщение при помощи SQL */
SELECT 'Минимальный средний балл ЕГЭ' AS Сообщение;
SELECT min(allavgege.avgege) FROM
(SELECT 
(SELECT avg(pege.score) FROM passedege AS pege 
WHERE pege.id_enrollee=enrollee.id) AS avgege FROM enrollee 
JOIN passedege ON enrollee.id=passedege.id_enrollee) AS allavgege;

/* Показать абитуриентов, у которых средний балл по ЕГЭ 
	меньше 45 и указать их баллы */
\echo '\n Абитуриенты со средним баллом по ЕГЭ меньшим 45'
SELECT DISTINCT tabwithavgege.id, tabwithavgege.name, 
tabwithavgege.avgege, 
get_enr_ege_stat(tabwithavgege.id) FROM
(SELECT enrollee.id AS id, enrollee.name AS name,
(SELECT avg(pege.score) FROM passedege AS pege 
WHERE pege.id_enrollee=enrollee.id) AS avgege FROM enrollee 
JOIN passedege 
ON enrollee.id=passedege.id_enrollee) AS tabwithavgege
WHERE tabwithavgege.avgege<45;

/* Показать абитуриента с самым низким средним баллом по ЕГЭ */
\echo '\n Абитуриент с самым низким средним баллом по ЕГЭ'
SELECT  DISTINCT tabwithavgege.id, tabwithavgege.name, 
tabwithavgege.avgege FROM
(SELECT enrollee.id AS id, enrollee.name AS name,
(SELECT avg(pege.score) FROM passedege AS pege 
WHERE pege.id_enrollee=enrollee.id) AS avgege FROM enrollee 
JOIN passedege 
ON enrollee.id=passedege.id_enrollee) AS tabwithavgege
WHERE tabwithavgege.avgege=
(SELECT min(allavgege1.avgege1) FROM
(SELECT 
(SELECT avg(pege1.score) FROM passedege AS pege1
WHERE pege1.id_enrollee=enrollee.id) AS avgege1 
FROM enrollee 
JOIN passedege 
ON enrollee.id=passedege.id_enrollee) AS allavgege1);

/* Показать абитуриентов, которые сдали больше 3 ЕГЭ */
\echo '\n Абитуриенты, которые сдали больше 3 ЕГЭ'
SELECT tab_enr_npe.id, tab_enr_npe.name, tab_enr_npe.npe 
AS "Число сданных ЕГЭ" 
FROM
(SELECT DISTINCT enrollee.id AS id, enrollee.name AS name, 
(SELECT count(*) FROM enrollee AS enr1 
JOIN passedege AS pe1 ON enr1.id=pe1.id_enrollee 
WHERE enr1.id=enrollee.id) AS npe
FROM enrollee JOIN passedege ON enrollee.id=passedege.id_enrollee) 
AS tab_enr_npe
WHERE tab_enr_npe.npe>3;

-- Запросы с LIKE
\echo '\n Запросы с LIKE' 
/* Вывести фамилию и дату рождения всех абитуриентов */
/* 	в ФИО которых содержится строка 'нар' */
\echo '\n Абитуриенты, в ФИО которых есть строка "нар"' 
SELECT name,dob
FROM enrollee WHERE name LIKE '%нар%';

/* Вывести также гражданство таких абитуриентов */
\echo '\n Вывести также гражданство таких абитуриентов' 
/* По умолчанию подразумевается inner JOIN */
/* При наличии LEFT, RIGHT, FULL - outer JOIN */
SELECT enrollee.name,enrollee.dob,citizenship.name 
FROM enrollee 
JOIN enrollee2citizenship 
ON enrollee2citizenship.id_enrollee=enrollee.id 
JOIN citizenship 
ON citizenship.id=enrollee2citizenship.id_citizenship  
WHERE enrollee.name LIKE '%нар%';

-- Запросы с GROUP BY
\echo '\n Запросы с GROUP BY'
/* Сколько граждан каждой из стран среди абитуриентов? */
\echo '\n Запросы с GROUP BY'

\echo '\n Распределение абитуриентов по гражданству'
SELECT c.name, count(*) 
/* в разделе выбора столбцов 
	при применении GROUP BY
	столбцы, не указанные в GROUP BY
	можно использовать ТОЛЬКО в агрегатных функциях */
FROM enrollee2citizenship AS e2c 
JOIN citizenship AS c 
 ON e2c.id_citizenship=c.id 
GROUP BY c.name 
ORDER BY c.name;

/* Фильтрация групп при помощи HAVING */
\echo '\n Фильтрация групп при помощи HAVING'

\echo '\n Распределение абитуриентов по гражданству'
\echo 'по странам, где число абитуриентов >10';
SELECT c.name, count(*)
FROM enrollee2citizenship AS e2c 
JOIN citizenship AS c 
 ON e2c.id_citizenship=c.id 
GROUP BY c.name
HAVING count(*)>10
ORDER BY c.name;

-- Запросы с SELECT INTO
\echo '\n Запросы с SELECT INTO'
/* Запишем в таблицу foreigners всех абитуриентов, 
имеющих иностранное гражданство */
\echo 'Запишем в таблицу foreigners'
\echo 'абитуриентов с иностр. гражданством'
/* Таблица при использовании SELECT INTO
	создается автоматически */
SELECT enr.* INTO foreigners FROM
	enrollee AS enr
	JOIN enrollee2citizenship AS e2c
	 ON e2c.id_enrollee=enr.id
	JOIN citizenship AS c
	 ON e2c.id_citizenship=c.id
WHERE NOT c.name='Российская Федерация';
/* Проверим, сколько записей в foreigners */
\echo 'Проверим, что записалось';
SELECT count(*) FROM foreigners;


\echo 'Удалим таблицу foreigners'
DROP TABLE foreigners;

/* INSERT с подзапросом SELECT */

/* Создадим таблицу по образу и подобию enrollee 
	для студентов, сдававших ВИПС */
\echo '\n Создание таблицы при помощи LIKE'
\echo 'по образу и подобию enrollee'
CREATE table
IF NOT EXISTS
enrollee_vips
(LIKE enrollee INCLUDING ALL);
\echo 'Проверим, что в этой таблице ничего нет'
SELECT count(*) FROM enrollee_vips;

/* Добавим в нее студентов, которые сдавали ВИПС */
\echo 'Добавим в нее студентов, которые сдали ВИПС'
INSERT INTO enrollee_vips
SELECT DISTINCT enr.id FROM enrollee AS enr 
JOIN passedvips AS pv  ON enr.id=pv.id_enrollee;

\echo 'Проверим, сколько в ней записей'
SELECT count(*) FROM enrollee_vips;

\echo 'Удалим таблицу enrollee_vips'
DROP TABLE enrollee_vips;

-- Запросы с UNION
\echo '\n Запросы с UNION'
/* Объединим 2 запроса - студентов из КНР и Канады */
\echo '\n Объединим результаты 2-х запросов при помощи UNION'
\echo '1 - запрос - абит. из Канады, 2-й - из КНР'
/* Запросы должны быть совместимы по типу возвращаемых данных */
(SELECT enr.name,c.name FROM
	enrollee AS enr
	JOIN enrollee2citizenship AS e2c
	 ON e2c.id_enrollee=enr.id
	JOIN citizenship AS c
	 ON e2c.id_citizenship=c.id
WHERE c.name='Канада')
UNION
(SELECT enr.name,c.name FROM
	enrollee AS enr
	JOIN enrollee2citizenship AS e2c
	 ON e2c.id_enrollee=enr.id
	JOIN citizenship AS c
	 ON e2c.id_citizenship=c.id
WHERE c.name='КНР');

-- Прочие запросы
\echo '\nПрочие запросы'
/* Пример использования CASE и VALUES */
\echo '\nПример использования CASE и VALUES' 
SELECT 
(CASE WHEN column1>0 THEN 'q' ELSE '-q' END) 
FROM (VALUES (10),(-10),(20),(-20)) AS t1;

/* Получить первые 10 строк таблицы 
	при помощи LIMIT */
\echo '\n Получить первые 10 строк таблицы (LIMIT)'
SELECT enrollee.id,enrollee.name FROM enrollee LIMIT 10;	

/* Получить первые 10 строк таблицы 
	при помощи FETCH */
\echo '\n Получить первые 10 строк таблицы (FETCH)'
SELECT enrollee.id,enrollee.name FROM enrollee 
FETCH FIRST 10 ROWS ONLY;

\q
