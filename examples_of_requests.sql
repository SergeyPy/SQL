
--Задание1.Напишите запрос, который выводит все возможные уникальные пары даты доставки и имени водителя, упорядоченные по дате и имени по возрастанию.

	select
	    d.first_name,
	    s.ship_date
	from
	    shipping.driver d 
	        cross join shipping.shipment s
	order by 2,1 asc

