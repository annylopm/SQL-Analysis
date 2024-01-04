--Tablas
SELECT * FROM runners
SELECT * FROM customer_orders
SELECT * FROM runner_orders
SELECT * FROM pizza_names
SELECT * FROM pizza_recipes
SELECT * FROM pizza_toppings

--Data cleaning

--Tabla customer_orders
--Convertir valores nulos y valores de texto 'nulo' en la columna extras y en la columna exclusions en espacios en blanco '' 
select * from customer_orders

UPDATE customer_orders
SET exclusions = ''
WHERE exclusions IS NULL OR exclusions LIKE 'null'

UPDATE customer_orders
SET extras = ''
WHERE extras IS NULL or extras LIKE 'null'

--Tabla runner_orders
--Convertir valores de texto 'nulo' en pickup_time, duration, distance y cancellation  en valores nulos.
SELECT * FROM runner_orders

UPDATE runner_orders
SET pickup_time = NULL
WHERE pickup_time like 'null'

UPDATE runner_orders
SET duration = NULL
WHERE duration like 'null'

UPDATE runner_orders
SET distance = NULL
WHERE distance like 'null'

UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation like 'null'

--Convertir valores vacios en la columna cancellation  en valores nulos.
update runner_orders
SET cancellation = NULL
WHERE cancellation = ''

--Extraer los 'km' de la columna  distance y convertir a tipo de datos FLOAT
UPDATE runner_orders
SET distance = TRIM ('km' FROM distance)
WHERE distance LIKE '%km'

alter table runner_orders
alter column distance FLOAT

--Convertir la columna pickup_time  a tipo de datos timestamp without time zone
ALTER TABLE runner_orders
ALTER COLUMN pickup_time DATE

--Extraer los 'minutos' de la columna Duration y convertir a tipo de datos INT
select * from runner_orders

UPDATE runner_orders
SET duration = TRIM('mins' from duration)
where duration like '%mins'

UPDATE runner_orders
SET duration = TRIM('minutes' from duration)
where duration like '%minutes'

UPDATE runner_orders
SET duration = TRIM('minute' from duration)
where duration like '%minute'

ALTER TABLE runner_orders
ALTER COLUMN duration int
