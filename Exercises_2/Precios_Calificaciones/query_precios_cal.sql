--1)Si una pizza Meat Lovers cuesta $ 12 y una vegetariana cuesta $ 10 y no hubo cargos por cambios, 
--¿cuánto dinero ha ganado Pizza Runner hasta ahora si no hay tarifas de entrega?
select * from customer_orders
select * from runner_orders

SELECT 
SUM(CASE WHEN c.pizza_id = 1 THEN 12*1 ELSE 1*10 END) as ganancia
FROM customer_orders c
JOIN runner_orders r
ON(c.order_id = r.order_id)
WHERE r.cancellation IS NULL

--2)¿Qué pasa si hubo un cargo adicional de $ 1 por los extras de pizza? Nota: Agregar queso cuesta $1 extra

--Creamos una cte con la misma consulta de la consigna 1, donde tenemos la ganancia sin extras
with ganancias_pizzas as(
	SELECT c.Cod_ID,
	SUM(
		CASE WHEN c.pizza_id = 1 THEN 12*1 ELSE 10*1
		END
		) as ganancia
		from customer_orders c
		join runner_orders r ON (c.order_id = r.order_id)
		WHERE r.cancellation is NULL
		GROUP BY c.Cod_ID
),
gananacias_extras as(
	select c.Cod_ID, 
	--Si el topping_id de la tabla pizza_topping coincide con extras_toppings de la vista
	--pizza_extras, entonces sumamos 1, de lo contrario sumamos 0
	SUM(
		CASE when t.topping_id in(
			SELECT extras_toppings
			FROM pizza_extra e
			WHERE e.order_id = c.Cod_ID)
			THEN 1 ELSE 0 END
			) AS extras_menos_queso,
			--Si el topping_id de la tabla pizza_toppings coincide con extras_toppings de la vista
			-- pizza_extras y es queso, entonces sumamos 2, de lo contrario sumamos 0
			SUM(
			CASE WHEN t.topping_id IN(
				SELECT extras_toppings
				FROM pizza_extra e
				WHERE e.order_id = c.Cod_ID AND extras_toppings = 4)
				THEN 2 ELSE 0 
				END
			) as extra_queso
			FROM customer_orders c
			JOIN pizza_recipes_clean rc ON (c.pizza_id = rc.pizza_id)
			JOIN pizza_toppings t ON (rc.topping_id = t.topping_id)
			JOIN runner_orders r ON (c.order_id = r.order_id)
			WHERE cancellation is NULL
			GROUP BY c.Cod_ID
)
SELECT SUM(ganancia) + SUM(extras_menos_queso) + SUM(extra_queso) as ganancia_total
FROM ganancias_pizzas gp
JOIN gananacias_extras ge on (gp.Cod_ID = ge.Cod_ID) 

--3)El equipo de Pizza Runner ahora quiere agregar un sistema de calificación adicional que permita a los
--clientes calificar a su repartidor. 
--¿Cómo diseñaría una tabla adicional para este nuevo conjunto de datos? Genere un esquema para esta nueva tabla 
--e inserte sus propios datos para las calificaciones de cada cliente exitoso. Nota: ordene entre 1 a 5.

CREATE TABLE pizza_ratings(
	order_id INT,
	runner_id INT,
	rating int
)

INSERT INTO pizza_ratings(order_id, runner_id, rating)
VALUES  (1,1,3),
		(2,1,5),
		(3,1,2),
		(4,2,1),
		(5,3,5),
		(7,2,3),
		(8,2,4),
		(10,1,2)

--4)Usando su tabla recién generada, ¿puede unir toda la información para formar una tabla que tenga la siguiente información 
--para entregas exitosas? 
--customer_id,order_id,runner_id,rating,order_time,pickup_time, duration, 
--Average speed,Total number of pizzas
SELECT
c.customer_id,
c.order_id,
r.runner_id,
pr.rating,
c.order_time, 
r.pickup_time,
r.duration, 
ROUND(AVG(r.distance/r.duration*60), 1)AS avg_speed,
COUNT(c.order_id) AS pizza_count
FROM customer_orders c
JOIN runner_orders r
ON (r.order_id = c.order_id)
JOIN pizza_ratings pr
ON(c.order_id = pr.order_id)
GROUP BY
c.customer_id,
c.order_id,
r.runner_id,
c.order_time,
r.pickup_time,
r.duration,
pr.rating
ORDER BY order_id


--5)Si una pizza Meat Lovers costaba $12 y una vegetariana $10, precios fijos sin costo por extras, 
--y a cada repartidor se le paga $0.30 por kilómetro recorrido, 
--¿cuánto dinero le queda a Pizza Runner después de estas entregas?
WITH ganancias as (
	SELECT c.order_id,
		SUM(
			CASE
				WHEN c.pizza_id = 1 THEN 12*1
				ELSE 1*10
			END
			) AS ganancia
			FROM customer_orders c
			JOIN runner_orders r ON (c.order_id = r.order_id)
		WHERE r.cancellation IS NULL
		GROUP BY c.order_id
),
costo as(
	SELECT order_id,
		SUM(distance * 0.30) as costo_repartidores
	FROM runner_orders
	WHERE cancellation is NULL
	GROUP BY order_id
)
SELECT SUM(ganancia) - SUM(costo_repartidores) as ganancia_total
FROM ganancias g
JOIN costo o ON (g.order_id = o.order_id)



select * from customer_orders
select * from runner_orders

