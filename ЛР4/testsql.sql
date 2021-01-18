\c admission_office
/* Работает */
/* Функция проверяющая, является ли абитуриент с
	ID $1 победителем олимпиады 2 типа, необходимой 
	для поступления	на НП $2. 
	При этом проводится проверка минимального балла 
	ЕГЕ 
	Функция возвращает 0, поступление по олимпиаде 2 типа
	невозможно и число>0, если возможно. 
	*/
create or replace function check_olymp_t2(integer,varchar(10))
returns bigint
as $$
select count(*) from enrollee as enr 
join receivedcertificate as rc 
on enr.id=rc.id_enrollee 
join olympiadcertificate as oc 
on rc.id_olympiadcertificate=oc.id
join olympiadcertificate2speciality as oc2s 
on oc2s.id_olympiadcertificate=oc.id 
join olympiad on olympiad.id=oc.id_olympiad 
join benefitsforthewinners as bftw 
on bftw.id=olympiad.idbenefits 
where oc2s.speciality_code=$2 
and enr.id=$1 and 
(select ege_by_enr_subj(enr.id,oc.idsubject))>bftw.minimumegescore;
$$
language sql;

/* Функция определяет, является ли абитуриент победителем
	олимпиады типа 1 
	если не является - 0,
	если является > 0 */
create or replace function check_olymp_t1(integer)
returns bigint
as $$
select count(*) from enrollee as enr 
join receivedcertificate as rc on enr.id=rc.id_enrollee 
join olympiadcertificate as oc on rc.id_olympiadcertificate=oc.id
join olympiad as ol on ol.id=oc.id_olympiad
where ol.idbenefits=1 and enr.id=$1;
$$
language sql;

/* Функция, которая определяет балл ЕГЭ
по предмету олимпиады */
create or replace function ege_by_enr_subj(enr_id integer,subj_id integer)
returns smallint 
as $$
SELECT pe.score FROM
enrollee as enr join passedege as pe
on enr.id=pe.id_enrollee
where enr.id=enr_id and pe.id_subject=subj_id;
$$
language sql;

CREATE OR REPLACE FUNCTION subj_id_list(varchar(10))
RETURNS TABLE(id_subject integer)
AS $$
SELECT subject.id 
FROM subject JOIN subject2specialityege 
ON subject.id=subject2specialityege.idsubject 
WHERE subject2specialityege.speciality_code=$1;
$$ 
language SQL;


/* Функция проверяет, сдал ли абитуриент необходимые ЕГЭ */
create or replace function 
check_list_subj(enr_id integer, spec varchar(10))
returns integer
as $$
select
(case when 
(select count(*) from enrollee as enr 
join passedege as pe 
on enr.id=pe.id_enrollee
where enr.id=enr_id and
pe.id_subject in
(select subj_id_list(spec)))
=(select count(*) from (select subj_id_list(spec)) as subj_list)
then 1
else 0
end);
$$
language sql;

/* Функция для вычисления конкурсного балла */
create or replace function
count_conc_score(enr_id integer, spec varchar(10))
returns bigint
as $$

/* Сумма баллов за ЕГЭ по требуемым предметам,
	если нужные сданы */
	
/* Функция coalesce возвращает аргумент2, если аргумент 1 - NULL 
	иначе возвращает аргумент 1*/
select coalesce(sum1.score,0)*check_list_subj(enr_id,spec)+
1000*(check_olymp_t1(enr_id)+check_olymp_t2(enr_id,spec))

/* Баллы за инд. достижения */
+(select enr2.achievementpoints 
from enrollee as enr2 where enr2.id=enr_id) 

/* Баллы за ВИПС по предмету,
	связанному со специальностью */
+
coalesce((select sum(pv.score) from enrollee as enr2 
join passedvips as pv 
on enr2.id=pv.id_enrollee
where enr2.id=enr_id and
pv.id_subject=
(select subject_vips from speciality 
where speciality.speciality_code=spec)
),0)

from
/* Вычисление суммы баллов ЕГЭ по треб. предметам */
(select sum(pe.score) as score from enrollee as enr 
join passedege as pe 
on enr.id=pe.id_enrollee
where enr.id=enr_id and
pe.id_subject in
(select subj_id_list(spec))) as sum1
$$
language sql;




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
	
create or replace function
count_final_score(enr_id integer, spec varchar(10))
returns bigint
as $$
select count_conc_score(enr_id, spec)*2+
(case 
	when 
	(select enr.righttopriorityadmission 
	from enrollee as enr where enr.id=enr_id) is true then 1 
	else 0 
end)
$$
language sql;


/* Ф-я выдает рейтинг, поступающих
	на образовательную программу определенного факультета
	с учетом формы оплаты и квоты */
create or replace function
get_enr_rating (fac_id integer,
	pm_id integer,
	q_id integer, /* 0 воспр. NULL */
	sc varchar(10),
	fe integer)
returns table (
	-- row_number() over (order by fs desc) integer,
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
as $$
select 
	-- (row_number() over (order by fs desc)),
	enr.id, enr.name, 
	get_enr_ege_stat(enr.id), 
	get_enr_vips_stat(enr.id),
	get_enr_olymp_stat(enr.id),
	enr.achievementpoints,
	enr.righttopriorityadmission,
	count_conc_score(enr.id,sc) as cs,
	count_final_score(enr.id,sc) as fs,
	appl.enrolmentconsent as ec
	
from enrollee as enr 
join application as appl
on enr.id=appl.id_enrollee
join educationalprogram as ep
on ep.id=appl.id_educationalprogram

where appl.id_faculty=fac_id
and appl.id_paymentmethod=pm_id
and appl.id_quota is not distinct from 
(case when q_id=0 then NULL else q_id end)
and ep.speciality_code=sc
and ep.id_formofeducation=fe
order by fs desc;
$$
language sql;

/* Ф-я выдает список поступающих, реком. к зачислению
	на образовательную программу определенного факультета
	с учетом формы оплаты и квоты */
create or replace function
get_enr_adm_list (fac_id integer,
	pm_id integer,
	q_id integer, /* 0 воспр. NULL */
	sc varchar(10),
	fe integer)
returns table (
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
as $$

select Q.*, 
(select sum(pe.score) as score from enrollee as enr2 
join passedege as pe 
on enr2.id=pe.id_enrollee
where enr2.id=Q.id and
pe.id_subject in
(select subj_id_list(sc))) as egeresult
from
/* Добавляем к рейтингу абитуриентов новый порядковый номер */
(select (row_number() over (order by fs desc)) as id_final, id,
name, egestat, vipsstat, olympstat,	ap, rpa, cs, fs, ec
from get_enr_rating(fac_id,pm_id,q_id,sc,fe)) as Q 
/* Ограничения по количеству мест и согласию на зачисление */
where Q.id_final<=
	(select 
	pm2ep.numberofstudents 
	from paymentmethod2educationalprogram as pm2ep
	join educationalprogram as ep on
	pm2ep.id_educationalprogram=ep.id
	where ep.speciality_code=sc 
	and ep.id_formofeducation=fe
	and pm2ep.id_paymentmethod=pm_id
	)
	and Q.ec;
	
$$
language sql;

/* Функция, вычисляющая средний балл среди зачисленных
	на образовательную программу определенного факультета
	с учетом формы оплаты и квоты */
create or replace function
get_enr_adm_list_avg_ege (fac_id integer,
	pm_id integer,
	q_id integer, 
	sc varchar(10),
	fe integer)
returns numeric
as $$
select avg(Q.egeresult) from
(select egeresult from
get_enr_adm_list(fac_id,pm_id,q_id,sc,fe)
where egeresult is distinct from NULL
) as Q;
$$
language SQL;

/* Функция, вычисляющая проходной балл ЕГЭ среди зачисленных
	на образовательную программу определенного факультета
	с учетом формы оплаты и квоты */
create or replace function
get_enr_adm_list_min_ege (fac_id integer,
	pm_id integer,
	q_id integer, 
	sc varchar(10),
	fe integer)
returns bigint
as $$
select min(Q.egeresult) from
(select egeresult from
get_enr_adm_list(fac_id,pm_id,q_id,sc,fe)
where egeresult is distinct from NULL
) as Q;
$$
language SQL;


	

--select min_ege_by_enr_id(1);
--select enrollee.id, get_enr_ege_stat(enrollee.id),check_olymp_t2(enrollee.id,'030302') from enrollee where enrollee.id in (values (114),(137),(138),(139),(140));

/* Запросы для отладки */
/* Выведем инф-ю по абитуриентам 10,76,77,136
*/

\echo 'Инф-я по абитуриентам 10, 76, 77, 136'


select Y.id,Y.name as "ФИО",
Y.egestat as "ЕГЭ",Y.ap as "Б.И.Д.",Y.rpa as "П" 
from (values (10),(76),(77),(136)) as X, 
show_enrollee_by_id(X.column1) as Y;
	
/* Проверим работу функции check_olymp_t1 */
\echo '\n Проверка ф-ии check_olymp_t1 для абит. 136'
select check_olymp_t1(136);

/* Проверка функции check_list_subj */
\echo 'Проверка ф-ии check_list_subj для абит. 2'
select check_list_subj(2,'090301');
\echo 'Проверка ф-ии check_list_subj для абит. 72'
select check_list_subj(72,'090301');

/* Проверка функции count_count_conc_score */
\echo 'Проверка ф-ии count_conc_score' 
\echo 'для абит. 10 (090301,180301), 76, 77'
select count_conc_score(10,'090301');
select count_conc_score(10,'180301');
select count_conc_score(76,'090301');
select count_conc_score(77,'090301');
/* Проверка вычисления конкурсного балла
	Для случая, когда абитуриент является победителем 
	олимпиад, дающих привелегии типов 1 и 2 */
\echo '\n Информация по олимпиадам абитуриента 137'
select get_enr_olymp_stat(137);
select check_olymp_t1(137);
\echo '\n Проверка ф-ии count_conc_score для абит. 137 (090301,180301)'
select count_conc_score(137,'090301');
select count_conc_score(137,'180301');

/* Проверка вычисления итогового балла для абитуриентов 10, 76
	при поступлении на направление 090301 */
\echo '\n Вычисление итогового балла для абит. 10, 76'
select count_final_score(10,'090301');
select count_final_score(76,'090301');
	


/* Поступление на какие специальности возможно
	для победителей соответствующих олимпиад 
	с привелегиями 2 типа */
\echo '\n Связь специальностей и сертификатов победителей олимпиад'
select oc.id as "ID серт",oc.id_olympiad as "ID Олимп", 
oc2s.speciality_code from olympiadcertificate2speciality as oc2s 
join olympiadcertificate as oc on 
oc.id=oc2s.id_olympiadcertificate;

select 'Добавление специальности 090301 для серт. 1 и 2'
as Сообщение;
/* Добавим для возможность использования сертификатов 1 и 2 
	для поступления на специальность 090301 */
insert into olympiadcertificate2speciality
values(1,'090301');
insert into olympiadcertificate2speciality
values(2,'090301');

/* Проверим работу функции count_conc_score вновь 
	результат должен различаться более чем на 1000 
	ведь одна из олимпиад не зависит от специальности, 
	а другая зависит 
	*/
\echo '\n Повторная проверка count_conc_score'
\echo 'для абит. 10 (090301,180301), 76, 77'
select count_conc_score(137,'090301');
select count_conc_score(137,'180301');

/* Удалим добавленные выше записи из таблицы
	olympiadcertificate2speciality */
\echo '\n Удаление добавленных выше записей из'
\echo 'olympiadcertificate2speciality'
delete from olympiadcertificate2speciality where
id_olympiadcertificate<=2 and speciality_code='090301';

/* Куда были поданы заявления:
	факультет, ф. опл., квота, обр. программа */
\echo '\n Куда были поданы заявления?'
select distinct ap1.id_faculty,ap1.id_quota, 
ap1.id_educationalprogram, ap1.id_paymentmethod,
(select count(*) from application as ap2  
where ap2.id_faculty=ap1.id_faculty and
ap2.id_quota is not distinct from ap1.id_quota and
ap2.id_educationalprogram=ap1.id_educationalprogram
and ap2.id_paymentmethod=ap1.id_paymentmethod
) as quantity
from application as ap1;

/* Изменим предыдущий запрос так, 
чтобы вывод был более понятный */

\echo '\n Вывод пред запроса в более понятной форме' 
select distinct 
fac.id as "ID Фак",
fac.name as "Факультет",
ep.id_formofeducation as "Форма обуч.",
ap1.id_quota as "Квота", 
ep.speciality_code as "Направление",
pm.paymentmethodtype as "Способ оплаты", 
(select count(*) from application as ap2  
where ap2.id_faculty=ap1.id_faculty and
/* Со значениями NULL обычные операторы для сравнения
	не работают */
ap2.id_quota is not distinct from ap1.id_quota and
ap2.id_educationalprogram=ap1.id_educationalprogram
and ap2.id_paymentmethod=ap1.id_paymentmethod) as quantity
from application as ap1
join educationalprogram as ep
on ap1.id_educationalprogram=ep.id
join faculty  as fac 
on fac.id=ap1.id_faculty
join paymentmethod as pm 
on pm.id=ap1.id_paymentmethod;

/* Пусть абитуриенты из группы 1 Плана Генерации
	Данных поступают на места, финансируемые
	из средств федерального бюджета */
\echo '\n Пусть абит-ы из гр. 1 Плана Ген-и пост. на бюдж. места'
update application set id_paymentmethod=1
where id between 1 and 40;

/* Посмотрим, что изменилось в распределении заявлений */
\echo '\n Посмотрим, что изм. в распред. заявл.'
select distinct fac.name as "Факультет",
fac.id as "ID Фак",
ep.id_formofeducation as "Форма обуч.",
ap1.id_quota as "Квота", 
ep.speciality_code as "Направление",
pm.paymentmethodtype as "Способ оплаты", 
(select count(*) from application as ap2  
where ap2.id_faculty=ap1.id_faculty and
/* Со значениями NULL обычные операторы для сравнения
	не работают */
ap2.id_quota is not distinct from ap1.id_quota and
ap2.id_educationalprogram=ap1.id_educationalprogram
and ap2.id_paymentmethod=ap1.id_paymentmethod) as quantity
from application as ap1
join educationalprogram as ep
on ap1.id_educationalprogram=ep.id
join faculty  as fac 
on fac.id=ap1.id_faculty
join paymentmethod as pm 
on pm.id=ap1.id_paymentmethod;

/* Какие абитуриенты подали заявление на поступление в рамках квоты */
\echo '\n Проверим, никто ли не поступает в рамках квот?'
select enr.id,enr.name,appl.id_faculty from
enrollee as enr join application as appl
on enr.id=appl.id_enrollee
where appl.id_quota is distinct from NULL;
/* Абитуриенты не найдены */


/* Проверим работу ф-и, выводящей рейтинг абитуриентов */
\echo '\n Рейтинг ФПИК, бюджет, ОЗ, общ. осн., 090301'
select row_number() over (order by fs desc) as "№ в рейт.",
id, left(name,10) as "ФИО",egestat as "ЕГЭ",ap as "Б.И.Д.",
rpa as "Приор.",cs as "К.Б.",fs as "И. Б."
from get_enr_rating(5,1,0,'090301',2);

\echo '\n Рейтинг ФПИК, контракт, ОЗ, общ. осн., 090301'
select row_number() over (order by fs desc) as "№ в рейт.",
id, left(name,10) as "ФИО",vipsstat as "В.И.П.С.",ap as "Б.И.Д.",
rpa as "Приор.",cs as "К.Б.",fs as "И. Б."
from get_enr_rating(5,2,0,'090301',2);

\echo '\n Рейтинг ХТФ, контракт, О, общ. осн., 180301'
select row_number() over (order by fs desc) as "№ в рейт.",
id, left(name,10) as "ФИО",vipsstat as "В.И.П.С.",ap as "Б.И.Д.",
rpa as "Приор.",cs as "К.Б.",fs as "И. Б."
from get_enr_rating(2,2,0,'180301',1);

\echo '\n Рейтинг ФЭВТ, бюджет, О, общ. осн., 090301'
select row_number() over (order by fs desc) as "№ в рейт.",
id, left(name,10) as "ФИО",egestat as "ЕГЭ",
olympstat as "Олимп",
ap as "Б.И.Д.",
rpa as "Приор.",cs as "К.Б.",fs as "И. Б."
from get_enr_rating(1,1,0,'090304',1);


/* Проверим работу ф-и, выводящей список лиц, рекомендованных 
к зачислению */

/* Поскольку зачислению подлежат лишь лица, давшие согласие
	зачисление, то в целях тестирования пусть факт  согласия
	будет установлен для всех заявлений, хотя по закону 
	абитуриент может заявить о согласии на зачислении лишь по 1 
	заявлению */
\echo '\n В целях тестирования установим значение атрибута'
\echo 'enrolmentconsent=true для всех экз. сущности application'
update application set enrolmentconsent=true;
/* Проверим, остались заявления без согласия на зачисление */
\echo 'Проверим, остались ли заявления'
\echo 'без согласия на зачисление'
select count(*) from application where
enrolmentconsent=false;

\echo '\n Список лиц, рекомендованных к зачислению'
\echo 'ФЭВТ, бюджет, О, общ. осн., 090304'
select id_final as "№ в рейт.",
id, left(name,10) as "ФИО",egestat as "ЕГЭ", egeresult as "Балл ЕГЭ",
olympstat as "Олимп",
ap as "Б.И.Д.",
rpa as "Приор.",cs as "К.Б.",fs as "И. Б."
from get_enr_adm_list(1,1,0,'090304',1);

\echo '\n Список лиц, рекомендованных к зачислению'
\echo 'ФПИК, бюджет, О-З, общ. осн., 090301'
select id_final as "№ в рейт.",
id, left(name,10) as "ФИО",egestat as "ЕГЭ", egeresult as "Балл ЕГЭ",
ap as "Б.И.Д.",
rpa as "Приор.",cs as "К.Б.",fs as "И. Б."
from get_enr_adm_list(5,1,0,'090301',2);

/* Проверка работы ф-и, вычисляющей средний балл
	среди зачисленных */
\echo '\n Средний балл, среди зачисленных на'
\echo 'ФЭВТ, бюджет, О, общ. осн., 090304'
select get_enr_adm_list_avg_ege(1,1,0,'090304',1);

\echo '\n Средний балл, среди зачисленных на'
\echo 'ФПИК, бюджет, ОЗ, общ. осн., 090301'
select get_enr_adm_list_avg_ege(5,1,0,'090301',2);

\echo '\n Средний балл, среди зачисленных на'
\echo 'ФПИК, контракт, ОЗ, общ. осн., 090301'
select get_enr_adm_list_avg_ege(5,2,0,'090301',2);

\echo '\n Средний балл, среди зачисленных на'
\echo 'ХТФ, контракт, ОЗ, общ. осн., 180301'
select get_enr_adm_list_avg_ege(2,1,0,'180301',2);

-- Транзакционные операции
/* Добавим на химфак 1 абитуриента, поступающего через ЕГЭ */
\echo '\n Средний балл вычислить нельзя, потому что'
\echo 'все абитуриенты поступали через ВИПС'
\echo 'Добавим 1 абитуриента, поступавшего через ЕГЭ'
/* Регистрация абитуриента */
insert into enrollee values 
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
select id, name from enrollee where name='Иван Петров';

/* Регистрация заявления абитуриента */
insert into application values
	(default,
	2, -- ID факультета
	2, -- ID метода оплаты
	NULL, -- На общих основаниях
	4, -- ID образовательной программы
	146, -- ID абитуриента
	true);

\echo 'Убедимся, что запись в application добавлена'
select id from application where id_enrollee=146;

/* Регистрация результатов сдачи ЕГЭ */
insert into passedege values
	(default,
	146,
	3,
	date '01.06.2020',
	90);
insert into passedege values
	(default,
	146,
	1,
	date '02.06.2020',
	90);
insert into passedege values
	(default,
	146,
	5,
	date '03.06.2020',
	90);

-- Аналитические операции (продолжение)

\echo 'Убедимся, что запись в passedege добавлена'
select id from passedege where id_enrollee=146;

/* Вновь вычислим средний балл */
\echo '\n Средний балл, среди зачисленных на'
\echo 'ХТФ, контракт, ОЗ, общ. осн., 180301'
\echo 'с одним добавленным абитуриентом,'
\echo 'поступившем через ЕГЭ'
select get_enr_adm_list_avg_ege(2,2,0,'180301',1);

/* Удалим этого абитуриента */
\echo 'Удаляем этого абитуриента'
delete from enrollee where name='Иван Петров';
/* При этом автоинкрементальный атрибут ID 
	автоматически не уменьшается.
	Уменьшим его вручную */
\echo 'Уст. для счетчика атр. id сущности enrollee значение 145'
select setval('enrollee_id_seq',145);

\echo '\n Убедимся, что запись в application удалилась автоматически'
\echo 'благодаря on delete cascade для внешнего ключа id_enrollee'
select id from application where id_enrollee=146;
\echo 'Уст. для счетчика атр. id сущности application значения 150'
select setval('application_id_seq',150);

\echo 'Убедимся, что запись из passedege удалилась автоматически'
select id from passedege where id_enrollee=146;
\echo 'Уст. для счетчика атр. id сущности passedege значения 40'
select setval('passedege_id_seq',335);



/* Специально уменьшим число мест 
	на ФЭВТ, 090304, 
	чтобы проверить,
	как вычисляется средний балл */
\echo '\n Уменьшим число мест ФЭВТ по напр. 090304 до 2-х'
\echo 'чтобы проверить как вычисляется средний балл'
update paymentmethod2educationalprogram
set numberofstudents=2 
where id=3;

\echo '\n Список рекомендованных к зачислению по направлению 090304';	
\echo 'на бюджетные места при числе мест 2';
select id_final as "№ в рейт.",
id, left(name,10) as "ФИО",egestat as "ЕГЭ", egeresult as "Б. ЕГЭ",
olympstat as "Ол.",
ap as "ИД",
rpa as "П",cs as "КБ",fs as "ИБ"
from get_enr_adm_list(1,1,0,'090304',1);

\echo '\n Средний балл, среди зачисленных на'
\echo 'Рейтинг ФПИК, бюджет, ОЗ, общ. осн., 090301'
\echo 'При числе мест 2 человека'
select get_enr_adm_list_avg_ege(1,1,0,'090304',1);

/* Вернем прежнее количество мест */
\echo '\n Восстановим прежнее количество мест'
update paymentmethod2educationalprogram
set numberofstudents=40 
where id=3;

/* План зачисления абитуриентов (общие основания) */
\echo '\n План зачисления абитуриентов (общ. основания)'
select 
	br.name as "Филиал",
	f.name as "Ф-т",
	ep.speciality_code as "Код НП",
	toe.name as "Форма об.",
	pm.paymentmethodtype as "Оплата",
	pm2ep.numberofstudents as "Места",
	(select count(*) from application as ap  
		where 
		ap.id_faculty=f.id and
		/* Со значениями NULL обычные операторы для сравнения
		не работают */
		ap.id_quota is not distinct from NULL and
		ap.id_educationalprogram=ep.id
		and ap.id_paymentmethod=pm.id
	) as "Заявления"
	
from 
	branch as br
	join faculty as f
	on br.id=f.id_branch
	join paymentmethod2educationalprogram as pm2ep
	on pm2ep.id_faculty=f.id
	join educationalprogram as ep
	on pm2ep.id_educationalprogram=ep.id
	join typeofeducation as toe
	on toe.id=ep.id_formofeducation
	join paymentmethod as pm on
	pm2ep.id_paymentmethod=pm.id;

/* Определение наличия недобора абитуриентов */
\echo '\n Определение направлений с недобором';
select Q.* 
FROM
(select 
	br.name as "Филиал",
	f.name as "Ф-т",
	ep.speciality_code as "Код НП",
	toe.name as "Форма об.",
	pm.paymentmethodtype as "Оплата",
	pm2ep.numberofstudents as "Места",
	(select count(*) from application as ap  
		where 
		ap.id_faculty=f.id and
		/* Со значениями NULL обычные операторы для сравнения
		не работают */
		ap.id_quota is not distinct from NULL and
		ap.id_educationalprogram=ep.id
		and ap.id_paymentmethod=pm.id
	) as "Заявления"
	
from 
	branch as br
	join faculty as f
	on br.id=f.id_branch
	join paymentmethod2educationalprogram as pm2ep
	on pm2ep.id_faculty=f.id
	join educationalprogram as ep
	on pm2ep.id_educationalprogram=ep.id
	join typeofeducation as toe
	on toe.id=ep.id_formofeducation
	join paymentmethod as pm on
	pm2ep.id_paymentmethod=pm.id) as Q
WHERE Q."Места">Q."Заявления";
	
	
-- -- Запросы с SELECT INTO


-- /* Запишем в таблицу foreigners всех абитуриентов, 
-- имеющих иностранное гражданство */
-- \echo 'Запишем в таблицу foreigners'
-- \echo 'абитуриентов с иностр. гражданством'
-- /* Таблица при использовании SELECT INTO
	-- создается автоматически */
-- select enr.* into foreigners from
	-- enrollee as enr
	-- join enrollee2citizenship as e2c
	-- on e2c.id_enrollee=enr.id
	-- join citizenship as c
	-- on e2c.id_citizenship=c.id
-- where not c.name='Российская Федерация';
-- /* Проверим, сколько записей в foreigners */
-- \echo 'Проверим, что записалось';
-- select count(*) from foreigners;


-- \echo 'Удалим таблицу foreigners'
-- drop table foreigners;

-- /* insert с подзапросом select */

-- /* Создадим таблицу по образу и подобию enrollee 
	-- для студентов, сдававших ВИПС */
-- \echo '\n Создание таблицы при помощи LIKE'
-- \echo 'по образу и подобию enrollee'
-- create table
-- if not exists
-- enrollee_vips
-- (like enrollee including all);
-- \echo 'Проверим, что в этой таблице ничего нет'
-- select count(*) from enrollee_vips;

-- /* Добавим в нее студентов, которые сдавали ВИПС */
-- \echo 'Добавим в нее студентов, которые сдали ВИПС'
-- insert into enrollee_vips
-- select distinct enr.id from enrollee as enr join passedvips as pv on enr.id=pv.id_enrollee;

-- \echo 'Проверим, сколько в ней записей'
-- select count(*) from enrollee_vips;

-- \echo 'Удалим таблицу enrollee_vips'
-- drop table enrollee_vips;

-- -- Запросы с UNION
-- /* Объединим 2 запроса - студентов из КНР и Канады */
-- \echo '\n Объединим результаты 2-х запросов при помощи UNION'
-- \echo '1 - запрос - абит. из Канады, 2-й - из КНР'
-- /* Запросы должны быть совместимы по типу возвращаемых данных */
-- (select enr.name,c.name from
	-- enrollee as enr
	-- join enrollee2citizenship as e2c
	-- on e2c.id_enrollee=enr.id
	-- join citizenship as c
	-- on e2c.id_citizenship=c.id
-- where c.name='Канада')
-- UNION
-- (select enr.name,c.name from
	-- enrollee as enr
	-- join enrollee2citizenship as e2c
	-- on e2c.id_enrollee=enr.id
	-- join citizenship as c
	-- on e2c.id_citizenship=c.id
-- where c.name='КНР');



\q
