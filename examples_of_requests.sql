
--Задание1.Напишите запрос, который выводит все возможные уникальные пары даты доставки и имени водителя, упорядоченные по дате и имени по возрастанию.

	select
	    d.first_name,
	    s.ship_date
	from
	    shipping.driver d 
	        cross join shipping.shipment s
	order by 2,1 asc

_______

--Напишите запрос, который создает уникальный алфавитный справочник всех городов, штатов, имен водителей и производителей грузовиков. 
--Результатом запроса должны быть два столбца (название объекта и тип объекта — city, state, driver, truck). 
--Отсортируйте список по названию объекта, а затем по типу. 
	SELECT
	    distinct c.city_name object_name,
	    'city' type_object
	from
	    shipping.city c
	union all
	--------------------------
	SELECT
	    distinct c.state object_name,
	    'state' type_object
	from
	    shipping.city c
	union all
	--------------------------
	SELECT
	    distinct d.first_name object_name,
	    'driver' type_object
	from
	    shipping.driver d
	union all
	--------------------------
	SELECT
	    distinct t.make object_name,
	    'truck' type_object
	from
	    shipping.truck t
	order by object_name , type_object

_______

--Напишите запрос, который объединит в себе все почтовые индексы водителей и их телефоны в единый столбец-справочник. 
--Также добавьте столбец с именем водителя и столбец с типом контакта ('phone' или 'zip' в зависимости от типа). 
--Упорядочите список по столбцу с контактными данными по возрастанию, а затем по имени водителя. 

	select
	    d.zip_code::text object_name,
	    d.first_name,
	    'zip_code' object_type
	from
	    shipping.driver d
	union all
	------------------------------
	select
	    d.phone object_name, 
	    d.first_name,
	    'phone' object_type
	from
	    shipping.driver d
	order by object_name asc, first_name    

_______

-- Напишите запрос, который выводит общее число доставок ('total_shippings'), а также количество доставок в каждый день. 
--Необходимые столбцы: date_period,cnt_shipping. Не забывайте о единой типизации. Упорядочите по убыванию столбца date_period. 

	select
	    s.ship_date::text date_period,
	    count(s.*) cnt_shipping
	from 
	    shipping.shipment s
	group by s.ship_date
	union all
	select
	    'total' total_ship,
	    count(ss.*) cnt
	from 
	    shipping.shipment ss
	order by date_period desc

_______


--Напишите запрос, который выводит два столбца: city_name и shippings_fake. В первом столбце название города, а второй формируется так: 
--Если в городе было более 10 доставок, вывести количество доставок в этот город как есть. 
--Иначе вывести количество доставок, увеличенное на 5. 
--Отсортируйте по убыванию получившегося «нечестного» количества доставок, а затем по имени в алфавитном порядке. 

	select
	    c.city_name city,
	    count(s.*) shipping_fake
	from
	    shipping.shipment s
	        left join shipping.city c on s.city_id = c.city_id
	group by c.city_name
	having
	    count(s.*) > 10
	union all
	select
	    c.city_name,
	    count(s.*)*5 shipping_fake
	    
	from
	    shipping.shipment s
	        left join shipping.city c on s.city_id = c.city_id
	group by c.city_name
	having
	    count(s.*) < 10
	order by shipping_fake desc, city

_______



-- выведите список столбцов которые есть в таблице shipment но нет в других таблицах. Отсортируйте столбцы по возрастанию.
	select
	    c.column_name 
	from
	    information_schema.columns c
	where 
	    c.table_name = 'shipment' and c.table_schema = 'shipping'
	except
	select
	    c.column_name 
	from
	    information_schema.columns c
	where 
	    c.table_name = 'customer' and c.table_schema = 'shipping'
	except
	select
	    c.column_name 
	from
	    information_schema.columns c
	where 
	    c.table_name = 'driver' and c.table_schema = 'shipping'
	except
	select
	    c.column_name 
	from
	    information_schema.columns c
	where 
	    c.table_name = 'city' and c.table_schema = 'shipping'
	except
	select
	    c.column_name 
	from
	    information_schema.columns c
	where 
	    c.table_name = 'truck' and c.table_schema = 'shipping'



-- Напишите запрос, который выводит все схемы и названия таблиц в базе, в которых нет первичных ключей. Отсортируйте оба столбца в алфавитном порядке (по возрастанию). 
	select
	 t.table_schema,
	 t.table_name
	from 
	    information_schema.tables t
	where
	    exists(
	        select
	            *
	        from
	            information_schema.table_constraints c
	        where
	            t.table_name = c.table_name 
	            and 
	            t.table_schema = c.table_schema
	            and
	            c.constraint_type != 'PRIMARY KEY'
	    )
	order by 1,2 asc


-- Напишите запрос, который выводит названия всех городов и булевы поля, показывающие наличие клиентов, наличие водителей и наличие доставок в этом городе. Добавьте сортировку по названию городов. 
	select
	    c.city_name,
	    exists
	    (
	        select
	         *
	        from
	            shipping.shipment s
	        where
	            c.city_id = s.city_id
	    ) has_ship,
	    exists
	    (
	        select
	         *
	        from
	            shipping.customer cc
	        where
	            c.city_id = cc.city_id
	    ) is_cust,
	    exists
	    (
	        select
	         *
	        from
	            shipping.driver d
	        where
	            c.city_id = d.city_id
	    ) is_driver
	from
	    shipping.city c
	order by 1


--Напишите запрос, который найдет водителя, совершившего наибольшее количество доставок одному клиенту. В выводе должна быть одна строка, 
--которая содержит имя водителя (first_name), имя клиента и количество доставок водителя этому клиенту. 
	select
	    d.first_name driver,
	    c.cust_name customer,
	    a.cnt
	from
	    (
	        select
	            s.driver_id,
	            s.cust_id,
	            count(s.*) cnt
	        from
	            shipping.shipment s
	        group by 1,2
	        order by 1,2
	    ) a join shipping.driver d on a.driver_id = d.driver_id
	    join shipping.customer c on a.cust_id = c.cust_id
	order by a.cnt desc
	limit 1

--Используя конструкцию select from select, преобразуйте предыдущий запрос таким образом, чтобы он вывел: 
--имя водителя (first_name)
--имя клиента
--количество доставок этому клиенту общее количество доставок водителя 
--Подсказка: нам понадобятся данные из таблицы shipping.shipment. Объедините ее с таблицей из предыдущего запроса по полю driver_id. 
	select
	    d.first_name driver,
	    c.cust_name customer,
	    a.cnt,
	    a.cnt_all
	from
	    (
	    select
	        s.driver_id,
	        s.cust_id,
	        count(s.*) cnt,
	        gr.cnt_all
	    from
	        (select
	            ss.driver_id,
	            count(*) cnt_all
	        from
	            shipping.shipment ss
	        group by
	            ss.driver_id) gr 
	        join shipping.shipment s on s.driver_id = gr.driver_id
	    group by 1,2,4
	    order by 1,2) a 
	    join shipping.driver d on a.driver_id = d.driver_id
	    join shipping.customer c on a.cust_id = c.cust_id
	order by a.cnt desc

--Преобразовав запрос из предыдущего задания, напишите такой запрос, который найдет водителя, совершившего наибольшее число доставок одному клиенту. По этому водителю выведите следующие поля: 
--имя водителя
--имя самого частого для него клиента
--дату последней доставки этому клиенту
--общее число доставок этого водителя
--количество различных грузовиков, на которых он совершал доставку грузов 

	select
	    d.first_name driver,
	    c.cust_name customer,
	    a.cnt,
	    a.cnt_all,
	    a.last_date_ship,
	    a.cnt_truck
	from
	    (
	    select
	        s.driver_id,
	        s.cust_id,
	        max(s.ship_date) last_date_ship,
	        count(s.*) cnt,
	        gr.cnt_all,
	        count(distinct s.truck_id) cnt_truck
	    from
	        (select
	            ss.driver_id,
	            count(*) cnt_all
	        from
	            shipping.shipment ss
	        group by
	            ss.driver_id) gr 
	        join 
	            shipping.shipment s on s.driver_id = gr.driver_id
	        group by 1,2,5
	        order by 1,2) a 
	    join shipping.driver d on a.driver_id = d.driver_id
	    join shipping.customer c on a.cust_id = c.cust_id
	order by a.cnt desc
	limit 1

-- Представим, что в компании было два директора: Paolo Lorenzo и его сын Nicco Lorenzo. Первый руководил компанией с начала и до 2017-02-01 невключительно, 
-- второй — с 2017- 02-01 включительно и до конца периода. Напишите запрос, который даст следующий отчет: имя и фамилия директора в одном поле, далее поля со сводной статистикой 
--по доставкам (кол-во доставок, кол-во совершивших доставки водителей, кол-во клиентов, которым была оказана услуга доставки, и общая масса перевезенных грузов). 
	with paolo as (
	 
	    select
	        s.*
	    from
	        shipping.shipment s
	    where
	        s.ship_date::date < '2017-02-01'::date
	),
	nicco as (
	
	    select
	        s.*
	    from
	        shipping.shipment s
	    where
	        s.ship_date::date >= '2017-02-01'::date
	)
	
	select
	    'Paolo Lorenzo',
	    count(distinct p.ship_id) count_ship,
	    count(distinct p.driver_id) count_driver,
	    count(distinct p.cust_id) count_cust,
	    sum(p.weight) sum_all_weight
	from
	    paolo p 
	union
	select
	    'Nicco Lorenzo',
	    count(distinct n.ship_id) count_ship,
	    count(distinct n.driver_id) count_driver,
	    count(distinct n.cust_id) count_cust,
	    sum(n.weight) sum_all_weight
	from
	    nicco n
        
        
--Напишите запрос, который посчитает среднюю (по штату) массу доставки. Используя его как подзапрос, выведите название штата, категорию доставок, где масса больше ('more'), масса меньше ('less'), равна('equal') или не заполнено ('null'), а также количество таких доставок. Штаты без доставок выводить не нужно. Отсортируйте по первому столбцу. 
--Столбцы в выдаче:
--state — название штата;
--category — категория доставок (текстовый столбец, значения 'more','less','equal','no_value'); 
--qty — количество доставок. 
	select
	   
	    w.state,
	    case
	        when w.avg_weight > ss.weight then 'more'
	        when w.avg_weight = ss.weight then 'equal'
	        when w.avg_weight < ss.weight then 'less'
	    end avg_weight,
	    count(ss.*)
	 
	from
	(  select
	        c.state,
	        avg(s.weight) avg_weight
	    from
	        shipping.shipment s
	        join shipping.city c on s.city_id = c.city_id
	    group by 1
	) w join shipping.city c on w.state = c.state
	    join shipping.shipment ss on c.city_id = ss.city_id
	group by 1,2
	order by 1

--Напишите запрос, который посчитает число сотен доставок, которые есть в сервисе: целое и вещественное. 
--Столбцы в выдаче:
--ships_100_int — целочисленные сотни; 
--ships_100_num — вещественные сотни. 

	select
	    count(s.ship_id) ships_100_int,
	    count(s.ship_id)::numeric ships_100_num 
	from
	    shipping.shipment s

--Напишите запрос, который посчитает долю количества численных столбцов от общего количества столбцов для каждой таблицы схемы shipping. Отсортируйте по убыванию этой доли. 
--Столбцы в выдаче:
--table_name — название таблицы; 
--numbers_ratio — доля численных столбцов. 

	select
	    c.table_name,
	    (count(
	    case
	        when c.data_type in ('integer','numeric','bigint') then c.column_name
	    end
	    )::numeric / count(c.*))  numbers_ratio
	from
	    information_schema.columns c
	where
	    c.table_schema = 'shipping'
	group by 1

--Представим, что в нашем справочнике shipping.truck ошиблись, и у грузовика под номером 8 производитель GMC. 
--Напишите запрос, который считает количество доставок по производителю, с учетом корректировки. Отсортируйте выдачу по названию производителя. 

	select
	    case 
	        when t.truck_id = 8 then 'GMC'
	        else t.make 
	    end make,
	    count(s.*)
	from
	    shipping.truck t join shipping.shipment s on t.truck_id = s.truck_id
	group by 1
	order by 1

--Напишите запрос, который выведет название всех столбцов в схеме shipping и столбец size, вычисляемый следующим образом: 
--максимально возможный размер в октетах (байтах), если он заполнен;
--если нет, то точность (объявленную или неявную) типа для целевого столбца; если и она не заполнена, то выведите 0. 
	select
	    c.column_name,
	    coalesce(c.character_octet_length, c.datetime_precision,0)
	from
	    information_schema.columns c
	where
	    c.table_schema = 'shipping'

--Для каждого города, в котором есть доставки, посчитайте соотношение числа доставок в эти города к числу клиентов, которые находятся в этом городе. Помните про целочисленность деления. Если клиентов нет, то в соотношение выведите NULL. Столбцы в выдаче:
--city_name — название города;
--ship_qty — число доставок;
--cust_qty — число клиентов;
--ratio — соотношение числа доставок к числу клиентов. 
--Отсортируйте по столбцу ratio. 
	select
	    cc.city_name,
	    a.cnt ship_qty,
	    count(distinct c.cust_id) cust_qty,
	    a.cnt/ count(distinct c.cust_id)::numeric ratio
	from
	    (
	        select
	            s.city_id,
	            count(s.city_id) cnt
	        from
	            shipping.shipment s 
	        group by 1
	    ) a join shipping.customer c on a.city_id = c.city_id
	        left join shipping.city cc on a.city_id = cc.city_id
	group by 1,2
	order by ratio desc

--Напишите запрос, который выводит число доставок по кажому производителю грузовиков, а также наименьшее и наибольшее среди них. 
--Столбцы в выдаче:
--Kenworth — кол-во доставок машинами Kenworth;
--Mack — кол-во доставок машинами Mack;
--Peterbilt — кол-во доставок машинами Peterbilt;
--maximum — наибольшее число доставок на производителя; minimum — наименьшее число доставок на производителя. 

	select
	    a.Kenworth,
	    a.Mack,
	    a.Peterbilt,
	    greatest(a.Kenworth,a.Mack,a.Peterbilt) max_all,
	    least(a.Kenworth,a.Mack,a.Peterbilt) min_all
	from
	    (
	    select
	        count(
	            case
	                when t.make = 'Kenworth' then  t.make 
	            end) Kenworth,
	        count(
	            case
	                when t.make = 'Mack' then  t.make
	            end) Mack,
	        count(
	            case
	                when t.make = 'Peterbilt' then  t.make
	            end) Peterbilt
	    from
	        shipping.shipment s join shipping.truck t on s.truck_id = t.truck_id
	    ) a

--Давайте узнаем, сколько сейчас времени в другом регионе, например Лос-Анджелесе. Напишите запрос, который выведет текущие время и дату в часовом поясе Лос-Анджелеса ("America/Los_Angeles"). 
--Столбцы в выдаче: now — время и дата в нужном часовом поясе. 

select now() at time zone 'America/Los_Angeles'

--Предположим, у нас есть дата и время какого-то события, и мы хотим посмотреть, к какой дате оно относится для Москвы и для UTC. Используя
--подзапрос with x as ( select '2018-12-31 21:00:00+00'::timestamp with time zone ts ) , 
--выведите дату в ts в Московском часовом поясе и в поясе UTC. 
--Столбцы в выдаче: 
--dt_msk — дата в московском часовом поясе dt_utc — дата в UTC 

	with x as (
	    select '2018-12-31 21:00:00+00'::timestamp with time zone ts 
	)
	
	select
	    x.ts::date at time zone 'Europe/Moscow',
	    x.ts::date at time zone 'UTC'
	from
	    x

--Давайте посчитаем помесячную статистику по доставкам, используя функцию extract. Напишите запрос, который выведет год, месяц и количество доставок. 
--Отсортируйте по году и по месяцу по возрастанию. Столбцы в выдаче: 
--year_n — номер года, month_n — номер месяца, qty — количество доставок. 

	select
	    EXTRACT(ISOYEAR FROM s.ship_date) year_n,
	    EXTRACT(month FROM s.ship_date) month_n,
	    count(s.*)
	from
	     shipping.shipment s
	group by 1,2

--Давайте составим справочник всех возможных часовых поясов, например для панели времени в аэропорте или лобби отеля. Напишите запрос, который выведет названия всех часовых поясов,
 --а также какому часу соответствует '21:00' в этих часовых поясах, из таблицы pg_timezone_names. Отсортируйте по названию по алфавиту. Столбцы в выдаче: 
--name — название часового пояса,
--hour — номер часа, целое число, например по умолчанию 21 

	select
	    tz.name,
	    '21:00'::time at time zone tz.name 
	from
	    pg_timezone_names tz
	order by name

--Давайте выведем текст текущего времени для сервиса точного времени. Напишите запрос, который выводит текст "Точное время x часов y минут z секунд", 
--где x,y,z — часы, минуты и секунды соответственно, при условии, что сообщение нужно вывести для московского часового пояса. Время введите в 24-часовом формате. 
--Столбцы в выдаче: msg — сообщение. 

	select to_char(current_timestamp,'"Точное время" HH24 "часов" MI"минут" SS"секунд"')

--Давайте подготовим данные для квартальной отчетности компании. Напишите запрос, который выведет дату доставки, округленную до квартала и общую массу доставок. 
--Отсортируйте по кварталу по возрастанию. Столбцы в выдаче: 
--q — начало квартала, тип date,
--total_weight — сумма масс доставок за квартал. 

	select
	    date_trunc('quarter',s.ship_date) q,
	    sum(s.weight) total_weight
	from
	    shipping.shipment s
	group by 1
	order by q

--Давайте оценим, сколько в каком интервале времени совершалось доставок в каждом городе в таблице с доставками. Напишите запрос, который выведет разницу между последним и 
--первым днем доставки по каждому городу. Отсортируйте по названию города, а затем по времени между доставками. Столбцы в выдаче: 
--city_name — название города,
--days_active — время от первой до последней доставки в днях. 

	select
	    s.city_id,
	    max(s.ship_date) - min(s.ship_date) days_active
	from
	    shipping.shipment s
	group by 1
	order by 1,2
	
--Давайте составим текстовый шаблон сообщения о доставке по конкретному водителю для наших клиентов. 
--Напишите SQL-запрос, который выведет следующее сообщение для каждого водителя: "Ваш заказ доставит водитель Имя Фамилия. 
--Его контактный номер: Номер", где Имя Фамилия и Номер взяты из справочника водителей. Если номер не указан, то выведите прочерк (-), используйте coalesce. 
--Пример из таблицы для наглядности: "Ваш заказ доставит водитель Adel Al-Alawi. Его контактный номер: (901) 947-4433". Столбцы в выдаче: msg — текст сообщения. 

	select
	     s.driver_id,
	    'Ваш заказ доставит водитель '|| d.first_name ||' '|| d.last_name ||'.'||
	    ' Его контактный номер '|| coalesce(d.phone,'-') msg
	from
	    shipping.shipment s left join shipping.driver d on s.driver_id = d.driver_id
	group by 1,2

--Давайте составим справочник названий клиентов, у которых более 10 доставок, в нижнем регистре, чтобы передавать их в другие системы (например, для обзвона), 
--которые не чувствительны к регистру. Напишите запрос, который выводит все id названия клиентов, у которых более 10 доставок в нижнем регистре, отсортируйте его по cust_id по возрастанию. 
--Столбцы в выдаче: 
--cust_id — id клиента
--cust_name — название клиента в нижнем регистре 
	select
	    lower(c.cust_name),
	    count(s.*)
	from
	    shipping.shipment s
	         left join shipping.customer c on s.cust_id = c.cust_id
	group by 1
	having
	    count(s.*) < 10
	
-- Напишите SQL-запрос, который выведет список сочетаний из справочника следующего вида: "название штата__название города", где названия штата и города взяты из справочника городов и переведены в 
--нижний регистр. Все символы пробела в городах и штатах замените символом '_'. Пример из таблицы для наглядности: "new_jersey__union_city" Столбцы в выдаче: utm — форматированный штат-город. 
--Отсортируйте по алфавиту полученный справочник. 

	select
	  replace(lower(c.state)||'__'||lower(c.city_name),' ','_')  utm
	from
	    shipping.city c
	order by 1

--Представим, что к вам пришел разработчик, который хочет сократить поле state в таблице city до 4-х символов, и попросил проверить, останется ли оно уникальным. 
--Напишите SQL-запрос, который выведет первые четыре символа названия штата, и количество уникальных названий штатов, которому они соотвествуют. 
--Оставьте только те, которые относятся к 2-м и более штатам. Добавьте сортировку по первому столбцу. Столбцы в выдаче:  
--code — 4 первых буквы штата,
--qty — количество уникальных названий штата, начинаюшихся на эти буквы. 

	select
	     left(c.state, 4) code,
	     count( left(c.state, 4) ) qt
	from
	    shipping.city c
	group by 1
	having count( left(c.state, 4) ) >= 2
	order by 1

--Напишите SQL-запрос, который выведет описание региона в следующем формате: " [city_name] is located in [state]. It's population is [population] people. Area is [area]".
-- Упорядочить необходимо по алфавиту по названию города. Пример: "Abilene is located in Texas. It's population is 115930 people. Area is 105.10". Столбцы в выдаче: str — сводка. 
	select
	    format($$ %s is located in %s. 
	    Its population is %s people. 
	    Area is %s $$, c.city_name,c.state,c.population,c.area )    str
	from
	    shipping.city c

--Пронумеруйте уникальными числами всех клиентов, отсортировав по имени в обратном порядке. Столбцы в выдаче: 
--cust_id — id клиента cust_name — имя клиента num — порядковый номер 
	select
	    c.cust_id,
	    c.cust_name,
	    row_number() over( order by c.cust_name desc) num
	from
	    shipping.customer c

--Предположим, вы хотите устроить акцию и вернуть бонусами деньги доставку трех самых тяжелых грузов для каждого клиента. Напишите запрос, который отранжирует все заказы для каждого клиента по массе груза по убыванию, и выберите 3 самых тяжелых из них. Столбцы в выдаче: 
--cust_id
--ship_id
--weight
--weight number (row_number для заказа по массе по клиенту) 


	select
	    *
	from
	    (select
	        s.cust_id,
	        s.ship_id,
	        s.weight,
	        row_number() over ( partition by s.cust_id  order by s.weight desc ) r
	    from
	        shipping.shipment s
	    ) x
	where
	    x.r <=3

--Давайте попрактикуемся в использовании общего окна для нескольких функций. Выведите результат ранжирования клиентов по годовой выручке по убыванию функциями row_number, rank, dense_rank, и
--спользуя общее окно. Столбцы в выдаче: 
--cust_name row_number rank dense_rank annual_revenue 
--Сортировка по annual_revenue по убыванию. 
	select
	    c.cust_name,
	    row_number() over wind,
	    rank() over wind,
	    dense_rank() over wind,
	    c.annual_revenue
	from
	    shipping.customer c
	window wind as (order by c.annual_revenue desc)