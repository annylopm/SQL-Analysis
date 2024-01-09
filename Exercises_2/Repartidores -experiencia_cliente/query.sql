--1)�Cu�ntos repartidores se inscribieron para cada per�odo de 1 semana? (es decir, la semana comienza el 2021-01-01)
SELECT 
	DATEPART(WEEK, registration_date) AS Semana,
	COUNT(runner_id) as cantidad_repartidores
FROM runners
GROUP BY DATEPART(WEEK, registration_date)

--2)�Cu�l fue el tiempo promedio en minutos que tard� cada repartidor en llegar a la sede de Pizza Runner para recoger el pedido?
WITH tmp as (
	SELECT r.runner_id, c.order_id, r.pickup_time, c.order_time,
	DATEDIFF(MINUTE, c.order_time, r.pickup_time) as tiempo_minutos
	FROM customer_orders c
	JOIN runner_orders_date r
	ON (c.order_id = r.order_id)
	WHERE r.cancellation is NULL
	GROUP BY r.runner_id, c.order_id, r.pickup_time, c.order_time
)
SELECT 
	runner_id,
	ROUND(AVG(tiempo_minutos), 2) AS promedio_minutos
FROM tmp
GROUP BY runner_id

--3)�Existe alguna relaci�n entre la cantidad de pizzas y el tiempo de preparaci�n del pedido?
WITH tmp as(
	SELECT
		COUNT(c.order_id) AS cantidad_de_pizzas, 
		DATEDIFF(MINUTE, c.order_time, r.pickup_time) as tiempo_minutos
	FROM customer_orders c
	JOIN runner_orders_date r
	on (c.order_id = r.order_id)
	WHERE r.cancellation IS NULL
	group by r.pickup_time, c.order_time
)
SELECT 
	cantidad_de_pizzas,
	ROUND(AVG(tiempo_minutos), 2) as promedio_preparacion
FROM tmp
GROUP BY cantidad_de_pizzas

--4)�Cu�l fue la distancia promedio recorrida por cada cliente?
SELECT 
	c.customer_id,
	ROUND(AVG(distance), 2) as distancia_promedio
FROM customer_orders c
JOIN runner_orders_date r
ON (c.order_id = r.order_id)
WHERE r.cancellation IS NULL
GROUP BY c.customer_id

--5)�Cu�l fue la diferencia entre los tiempos de entrega m�s largos y m�s cortos para todos los pedidos?
SELECT 
MAX(duration) - MIN(duration) AS diferencia_tiempos_entrega
FROM runner_orders

--6)�Cu�l fue la velocidad promedio de cada repartidor para cada entrega? �Observa alguna tendencia para estos valores?
SELECT 
	order_id, 
	runner_id,
	distance, 
	duration, 
	ROUND(AVG(distance/duration*60),2) AS velocidad_promedio
FROM runner_orders_date r
WHERE r.cancellation IS NULL
group by runner_id, order_id, distance, duration

--7)�Cu�l es el porcentaje de entrega exitosa para cada repartidor?
SELECT
runner_id,
COUNT(distance) AS entregado,
COUNT(order_id) AS total_ordenes,
100 * COUNT(distance) / COUNT(order_id) AS porcentaje_exitoso
FROM runner_orders_date
group by runner_id 
order by runner_id
