-- 10. Identify whether there may be some correlation between
-- the amount ordered and the time it takes to ship the order
-- Compute the average and standard deviation of the time per quantity of each order
-- EXAMPLE
# AVG, STDDEV
# '0.64447607', '0.5703154314602293'

SELECT AVG(timePerQuan) AS AVG, STD(timePerQuan) AS STDDEV FROM (
	SELECT order_id AS ORDER_ID, 
    (SELECT DATEDIFF(shipped_date, order_date))/(SELECT SUM(quantity) FROM order_items WHERE (orders.order_id = order_items.order_id)) AS timePerQuan	
	FROM
		customers, orders
	WHERE
		customers.customer_id = orders.customer_id
	GROUP BY
		ORDER_ID
	ORDER BY
		order_id ASC
) AS T;