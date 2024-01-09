--A. Viaje del cliente
--Con base en los 8 clientes de muestra provistos en la muestra de la tabla de suscripciones, escriba una breve 
--descripción sobre el viaje de incorporación de cada cliente.

select * from subscriptions
select * from plans

SELECT customer_id, plan_name, start_date_, price
FROM subscriptions s
JOIN plans p
ON (s.plan_id = p.plan_id)
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
ORDER BY  customer_id, start_date_

--El cliente 1 se registro con un plan de prueba de 7 días el 01/08/2020
--Después de ese tiempo no cancelo la suscripcion y continuo con un plan básico mendual el 08/08/2020

--El cliente 2 se registro con un plan de prueba el 20/09/2020
--Decidió continuar con un plan Pro de todo el año a después de que concluyo su plan de prueba el 27/09/2020

--El cliente 11 se registro con un plan de prueba de 7 días el 19/11/2020
--Cuando termino su plan, decidio cancelar su suscripcion el 26/11/2020

--El cliente 13 se registro con un plan de prueba el 15/12/2020
--Despues de ese tiempo, decidio continuar su sucripcion con un plan bascio mensual el 22/12/2020

--el cliente 15 se regsitro con un plan de prueba el 17/03/2020
--despues de ese tiempo, cambio su suscripcion a un plan Pro mensual el 24/03/2020
--Sin embargo canceló su suscripcion el 29/04/2020

--El cliente 16 se registro con un plan de prueba el 31/05/2020
--Pasado ese tiempo, decidio cambiar su suscripcion a un plan mensual basico el 07/06/2020
--Cambio su suscripcion a un plan Pro Anual el 21/10/2020

--El cliente 18 se registro con un plan de prueba el 06/07/2020
--Pasado el tiempo de prueba, cambio su suscripcion a un plan Mensual Pro el 13/07/2020

--El cliente 19 se registro con un plan de prueba el 22/06/2020
--Despues decidio cambiar su suscripcion a un plan Mensual Pro el 29/06/2020
--El 29/08/2020 cambio su suscripcion a un plan Anual Pro
