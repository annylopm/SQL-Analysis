--1)¿Cuántos clientes ha tenido Foodie-Fi?
SELECT COUNT(DISTINCT(customer_id)) AS cantidad_clientes
FROM subscriptions

--2)¿Cuál es la distribución mensual de los valores de la fecha de inicio del plan de prueba para nuestro conjunto de datos? 
--Utilice el inicio del mes como el grupo por valor
SELECT 
	DATEPART(MONTH, start_date_) as mes,
	COUNT (*) as cantidad
FROM subscriptions s
JOIN plans p
on (s.plan_id = p.plan_id)
WHERE p.plan_name = 'trial'
GROUP BY DATEPART(MONTH, start_date_)
ORDER BY mes

--3)¿Qué valores de plan start_date ocurren después del año 2020 para nuestro conjunto de datos? 
--Mostrar el desglose por conteo de eventos para cada plan_name
SELECT 
	DATEPART(YEAR, start_date_) as año,
	plan_name,
	COUNT (*) AS cantidad
FROM subscriptions s
JOIN plans p
ON (s.plan_id = p.plan_id)
WHERE DATEPART(YEAR, start_date_) > 2020
GROUP BY plan_name, DATEPART(YEAR, start_date_)

--4)¿Cuál es el recuento de clientes y el porcentaje de clientes que se han retirado redondeado a 1 decimal?
SELECT 
SUM(CASE WHEN p.plan_name = 'churn' THEN 1 ELSE 0 END) AS cantidas_clientes_baja,
CAST(100*SUM(CASE WHEN p.plan_name = 'churn' THEN 1 ELSE 0 END) AS FLOAT(1))/COUNT(DISTINCT(s.customer_id)) as procentaje_baja
FROM subscriptions s
JOIN plans p
ON (s.plan_id = p.plan_id)

--5)¿Cuántos clientes abandonaron inmediatamente después de su prueba gratuita inicial? 
--¿Qué porcentaje se redondea al número entero más cercano?
WITH nextPlan AS(
SELECT
	s.customer_id,
	s.start_date_,
	p.plan_name,
	LEAD(p.plan_name) OVER(PARTITION BY s.customer_id ORDER BY p.plan_id) as next_plan
FROM subscriptions s
JOIN plans p
ON (s.plan_id = p.plan_id)
)
SELECT
	COUNT (*) AS clientes_abandonaron,
	100*COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) as porcentaje_abandono
FROM nextPlan
WHERE plan_name = 'trial' AND next_plan = 'churn'


--6)¿Cuál es el número y porcentaje de planes de clientes después de su prueba gratuita inicial?
WITH nextPlan AS(
SELECT
	s.customer_id,
	s.start_date_,
	p.plan_name,
	LEAD(p.plan_name) OVER(PARTITION BY s.customer_id ORDER BY p.plan_id) AS next_plan
FROM subscriptions s
JOIN plans p
ON (s.plan_id = p.plan_id)
)

SELECT 
	next_plan,
	COUNT(*) AS cantidad,
	100*COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS porcentaje
FROM nextPlan
WHERE plan_name = 'trial' AND next_plan <> 'churn'
GROUP BY next_plan

--7)¿Cuál es el conteo de clientes y el desglose porcentual de los 5 valores de plan_name al 2020-12-31?
WITH plansDate AS(
SELECT 
	s.customer_id,
	s.start_date_,
	p.plan_id,
	p.plan_name,
	LEAD(s.start_date_) OVER(PARTITION BY s.customer_id ORDER BY s.start_date_) AS next_date
	FROM subscriptions s
	JOIN plans p
	on(s.plan_id = p.plan_id)
)
SELECT
	plan_id,
	plan_name,
	COUNT(*) AS customers,
	CAST(100*COUNT(*) AS FLOAT) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS rate
	FROM plansDate
	WHERE (next_date IS NOT NULL AND (start_date_ < '2020-12-31' AND next_date > '2020-12-31'))
	OR (next_date IS NULL AND start_date_ < '2020-12-31')
	GROUP BY plan_id, plan_name
	ORDER BY plan_id

--8)¿Cuántos clientes han actualizado a un plan anual en 2020?
SELECT 
	COUNT(DISTINCT s.customer_id) as clientes
FROM subscriptions s
JOIN plans p
ON (s.plan_id = p.plan_id)
WHERE p.plan_name = 'pro annual'
AND DATEPART(YEAR, s.start_date_) = 2020

--9)¿Cuántos días en promedio le toma a un cliente cambiar a un plan anual desde el día en que se une a Foodie-Fi?
WITH trialPlan AS(
SELECT
	s.customer_id,
	s.start_date_ AS trial_date
	FROM subscriptions s
	JOIN plans p 
	ON (s.plan_id = p.plan_id)
	WHERE p.plan_name = 'trial'
),
annualPlan as(
	SELECT 
	s.customer_id,
	s.start_date_ as annual_date
	FROM subscriptions s
	JOIN plans p
	ON (s.plan_id = p.plan_id)
	WHERE p.plan_name = 'pro annual'
)
SELECT 
ROUND(AVG(DATEDIFF(DAY, t.trial_date, a.annual_date)), 0)
FROM trialPlan t
JOIN annualPlan a
ON (t.customer_id = a.customer_id)




select * from plans
select * from subscriptions
