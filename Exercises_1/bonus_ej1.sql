select * from members
select * from menu
select * from sales

--1)Join all the things
SELECT 
	s.customer_id,
	s.order_date,
	e.product_name,
	e.price,
	(CASE WHEN s.order_date >= b.join_date THEN 'Y' ELSE 'N' END) as active_member
	FROM sales s
	JOIN menu e
	on (s.product_id = e.product_id)
	LEFT JOIN members b
	on (s.customer_id = b.customer_id)
	ORDER BY s.customer_id, s.order_date

--2) Rank all the things
WITH tmp as(
	SELECT 
	s.customer_id,
	s.order_date,
	e.product_name,
	e.price,
	(CASE WHEN s.order_date >= b.join_date THEN 'Y' ELSE 'N' END) as member_
	FROM sales s
	JOIN menu e
	on (s.product_id = e.product_id)
	LEFT JOIN members b
	on (s.customer_id = b.customer_id)
)
select *,
	CASE WHEN member_ = 'Y'
		THEN DENSE_RANK() OVER(PARTITION BY customer_id, member_ ORDER BY order_date)
	ELSE null END as ranking
from tmp
