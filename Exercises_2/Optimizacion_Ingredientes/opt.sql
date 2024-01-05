SELECT * FROM runners
SELECT * FROM customer_orders
SELECT * FROM runner_orders
SELECT * FROM pizza_names
SELECT * FROM pizza_recipes
SELECT * FROM pizza_toppings

--Para responder a las preguntas de negocio, realizaremos la siguientes sentencias:

--Agregamos una columna con un ID autoincremental  en la tabla customer_orders
select * from customer_orders

ALTER TABLE customer_orders
ADD Cod_ID int identity(1,1)

--Creamos una vista a partir de la tabla pizza_recipes, con una fila para cada topping de cada categoría de pizza.
select * from pizza_recipes

alter table pizza_recipes
alter column toppings varchar(max)


CREATE VIEW pizza_recipes_clean AS
SELECT pizza_id, CAST(value AS INT) AS topping_id
from pizza_recipes
CROSS APPLY
  STRING_SPLIT(toppings, ',')

select * from pizza_recipes_clean

--Creamos una segunda vista, con el numero de orden, la pizza pedida y si hubo extras o exclusiones
select * from customer_orders

drop view pizza_extra_exclusiones

CREATE VIEW pizza_exclusiones AS
SELECT order_id, 
		pizza_id, 
		CAST(value AS INT) AS exclusiones_toppings
from customer_orders
CROSS APPLY
  STRING_SPLIT(exclusions, ',') 

CREATE view pizza_extra AS
select order_id, 
		pizza_id, 
		CAST(value AS INT) AS extras_toppings  
from customer_orders
CROSS APPLY
	STRING_SPLIT(extras, ',')

select * from pizza_exclusiones
select * from pizza_extra

--1)¿Cuáles son los ingredientes estándar para cada pizza?
select * from pizza_names
SELECT * FROM pizza_recipes_clean
select * from pizza_toppings

alter table pizza_toppings
alter column topping_name VARCHAR(MAX)

select pizza_name,
STRING_AGG(t.topping_name, ', ') AS ingredientes
FROM pizza_names n JOIN pizza_recipes_clean r ON (n.pizza_id = r.pizza_id)
JOIN pizza_toppings t on (r.topping_id = t.topping_id)
GROUP BY pizza_name

--2)¿Cuál fue el extra más comúnmente añadido?
select * from pizza_extra
select * from pizza_toppings

SELECT t.topping_name, count(e.extras_toppings) as extras
from pizza_toppings t join pizza_extra e
on (t.topping_id = e.extras_toppings)
GROUP BY topping_name
order by extras desc

--3)¿Cuál fue la exclusión más común?
select * from pizza_exclusiones
select * from pizza_toppings

select t.topping_name, 
count(ex.exclusiones_toppings) as exclusiones
from pizza_toppings t join pizza_exclusiones ex
on (t.topping_id = ex.exclusiones_toppings)
group by topping_name
order by exclusiones desc

--4)Genere un artículo de pedido para cada registro en la tabla customers_orders en el formato de uno de los siguientes: 
--Meat Lovers / Meat Lovers - Exclude Beef / Meat Lovers - Extra Bacon / Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
select * from pizza_extra
select * from pizza_toppings

WITH extras as(
SELECT
	e.order_id,
	CONCAT('Extra ', STRING_AGG(t.topping_name, ' , ')) AS detalle
	FROM pizza_extra e JOIN pizza_toppings t
	ON (e.extras_toppings = t.topping_id)
	GROUP BY e.order_id
),
exclusions as(
	SELECT
	ex.order_id,
	CONCAT('Exclusión ', STRING_AGG(t.topping_name, ' , ')) as detalle
	from pizza_exclusiones ex join pizza_toppings t
	on (ex.exclusiones_toppings = t.topping_id)
	GROUP BY ex.order_id
),
tmp as(
	SELECT * FROM extras
	UNION 
	SELECT * FROM exclusions
)
SELECT  c.order_id,
		c.Cod_ID,
		c.customer_id,
		c.pizza_id,
		c.order_time,
		CONCAT_WS(' - ', p.pizza_name, STRING_AGG(tmp.detalle, ' - ')) as pizza_info
		from customer_orders c LEFT JOIN tmp
		on (c.Cod_ID = tmp.order_id)
		JOIN pizza_names p
		on (c.pizza_id = p.pizza_id)
GROUP BY
	c.order_id,
	c.Cod_ID,
	c.customer_id,
	c.pizza_id,
	c.order_time,
	p.pizza_name


select * from customer_orders
select * from pizza_names

--5)Genere una lista de ingredientes separados por comas ordenados alfabéticamente para cada pedido de pizza de la tabla customer_orders y agregue 2x 
--delante de cualquier ingrediente relevante Por ejemplo: "Amantes de la carne: 2xTocino, Carne de res, ... , Salami" /"Meat Lovers: 2xBacon, Beef, ... , Salami"
select * from pizza_extra
WITH ingredientes as(
	SELECT
		c.*,
		n.pizza_name,
		--Agregar '2x' delante de topping_names si su topping_id aparece en la vista extras y exclusiones
		CASE WHEN t.topping_id IN (
				SELECT e.extras_toppings
				FROM pizza_extra e
				WHERE e.order_id = c.Cod_ID)
			THEN CONCAT ('2x ', t.topping_name)
		--Excluir ingredientes si su topping_id aparece en la vista extras y exlusiones
			WHEN t.topping_id IN (
				SELECT ex.exclusiones_toppings
				FROM pizza_exclusiones ex
				WHERE ex.order_id = c.Cod_ID
			)
			THEN ''
			ELSE t.topping_name
			END as ingrediente
		FROM customer_orders c
		JOIN pizza_recipes_clean r
		ON (c.pizza_id = r.pizza_id)
		JOIN pizza_toppings t 
		ON (r.topping_id = t.topping_id)
		JOIN pizza_names n
		on (c.pizza_id = n.pizza_id)
)
SELECT 
	Cod_ID,
	order_id, 
	customer_id,
	pizza_id,
	order_time,
	CONCAT(pizza_name, ': ', STRING_AGG(ingrediente, ', ')) as lista_ingredientes
	FROM ingredientes
	GROUP BY
	Cod_ID, 
	order_id, 
	customer_id,
	pizza_id,
	order_time,
	pizza_name

--6)¿Cuál es la cantidad total de cada ingrediente utilizado en todas las pizzas entregadas ordenadas por el más frecuente primero?
WITH ingredientes as(
	SELECT 
	c.Cod_ID,
	t.topping_name,
	CASE
		--Ingrediente extra, suma 2
		WHEN t.topping_id IN (
			SELECT extras_toppings
			FROM pizza_extra e
			WHERE e.order_id = c.Cod_ID)
		THEN 2
		--Si se excluye un ingrediente, entonces es 0
		WHEN t.topping_id IN(
			SELECT exclusiones_toppings
			FROM pizza_exclusiones ex
			WHERE ex.order_id = c.Cod_ID)
		THEN 0
		--Sin extras ni exclusiones la cantidad es 1
		ELSE 1
	END AS cantidad
FROM customer_orders c
JOIN pizza_recipes_clean r
ON (c.pizza_id = r.pizza_id)
JOIN pizza_toppings t
ON (r.topping_id = t.topping_id)
)

SELECT topping_name, 
	SUM(cantidad) as cantidad_total
FROM ingredientes
GROUP BY topping_name
ORDER BY cantidad_total DESC
