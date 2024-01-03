select * from members
select * from menu
select * from sales

----1) ¿Cuál es la cantidad total que gastó cada cliente en el restaurante?
SELECT SUM(e.price) as total_gastado, s.customer_id
from menu e
join sales s ON (e.product_id = s.product_id)
GROUP BY s.customer_id
ORDER BY s.customer_id

----2) ¿Cuántos días ha visitado cada cliente el restaurante?
SELECT count(distinct(DAY(order_date))) as cantidad_visitas, customer_id
FROM "sales" 
GROUP BY customer_id
ORDER BY customer_id


----3) ¿Cuál fue el primer artículo del menú comprado por cada cliente?
select e.product_name, s.customer_id
from menu e JOIN sales s
ON (e.product_id = s.product_id)
where s.order_date = (select min(order_date) from sales)
group by s.customer_id, e.product_name
order by s.customer_id

--4) ¿Cuál es el artículo más comprado en el menú y cuántas veces lo compraron todos los clientes?
SELECT top (1) e.product_name,
count(*) as total_comprado
from sales s
join menu e
on s.product_id = e.product_id
GROUP BY e.product_name
order by total_comprado desc

--5) ¿Qué artículo fue el más popular para cada cliente?
WITH tmp as(
SELECT
e.product_name,
count(*) as total_comprado,
s.customer_id
from sales s
join menu e
on s.product_id = e.product_id
GROUP by e.product_name, s.customer_id
),
tmp_top as (
SELECT product_name, customer_id, total_comprado,
DENSE_RANK() OVER( PARTITION BY customer_id ORDER BY total_comprado desc) as rank_product
from tmp
)
select product_name, customer_id, total_comprado
from tmp_top
where rank_product = 1

select * from sales

--6) ¿Qué artículo compró primero el cliente después de convertirse en miembro?
with tmp as(
select 
e.product_name,
s.customer_id,
b.join_date,
s.order_date,
DENSE_RANK() over(PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rank_
from sales s
join menu e
on (s.product_id=e.product_id)
join members b
on (s.customer_id = b.customer_id)
where s.order_date >= b.join_date
)
select product_name, customer_id, join_date, order_date
from tmp
where rank_ = 1

--7)¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
with tmp as(
select 
s.customer_id,
e.product_name,
b.join_date,
s.order_date,
DENSE_RANK() over(partition by s.customer_id order by s.order_date asc) as rank_
from sales s
join menu e
on (s.product_id = e.product_id)
join members b
on (s.customer_id=b.customer_id)
where s.order_date < b.join_date
)
select customer_id, product_name, join_date, order_date
from tmp
where rank_ = 1

--8) ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
select s.customer_id,
COUNT(e.product_name) as total_comprado,
sum(e.price) as total_gastado
from sales s
join menu e
on (s.product_id = e.product_id)
join members b
on (s.customer_id = b.customer_id)
where s.order_date < b.join_date
group by s.customer_id
order by s.customer_id

--9) Si cada $ 1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos 2x, ¿cuántos puntos tendría cada cliente?
--Suposición: Solo los clientes que son miembros reciben puntos al comprar artículos, los puntos los reciben en las ordenes 
--iguales o posteriores a la fecha en la que se convierten en miembros. 
with tmp as(
select
s.customer_id,
SUM(CASE WHEN e.product_name = 'sushi' THEN e.price*20 ELSE 0 END) AS total_puntos_sushi,
SUM(CASE WHEN e.product_name <> 'sushi' THEN e.price*10 ELSE 0 END) AS total_puntos_otros_productos
FROM sales s
JOIN menu e
ON (s.product_id = e.product_id)
JOIN members b
ON (s.customer_id = b.customer_id)
WHERE s.order_date >= b.join_date
GROUP BY s.customer_id
)
select * --customer_id, (total_puntos_sushi + total_puntos_otros_productos) as total_puntos
from tmp
order by customer_id

--10) En la primera semana después de que un cliente se une al programa (incluida la fecha de ingreso),
--gana el doble de puntos en todos los artículos, no solo en sushi.
--¿Cuántos puntos tienen los clientes A y B a fines de enero?
--Suposición: Solo los clientes que son miembros reciben puntos al comprar artículos, los puntos los reciben en las ordenes 
--iguales o posteriores a la fecha en la que se convierten en miembros. Solo las ordenes de la primer semana en la que se convierten
--en miembros suman 20 puntos para todos los articulos. 
WITH fechas as(
SELECT 
	customer_id,
	join_date,
	DATEADD (DAY, 6, join_date) as primera_semana,
	--join_date + CAST('6 days' AS INTERVAL) AS primera_semana,
	CAST('2021-01-31' AS DATE) AS ultima_fecha
	FROM members
)
select * from fechas
select 
	f.customer_id,
	SUM(CASE 
		WHEN s.order_date BETWEEN f.join_date AND f.primera_semana THEN e.price*20
		WHEN e.product_name = 'sushi' THEN e.price*20
		ELSE e.price*10 END) as total_puntos
FROM sales s
JOIN fechas f
ON (s.customer_id = f.customer_id)
JOIN menu e
on (s.product_id = e.product_id)
where s.order_date <= f.ultima_fecha and s.order_date >= f.join_date
group by f.customer_id
order by f.customer_id

