-- 9. List information about each order.
-- Retrieve NAME, ORDER_ID, TOTAL_PRICE_BEFORE_DISCOUT, TOTAL_DISCOUNT
-- NAME includes both first and last customer name appended with with a space character in between. 
-- TOTAL_PRICE_BEFORE_DISCOUNT is the number of items multiplied by the list prices of those items, added up over all items in the order
-- TOTAL_DISCOUNT is the sum of the discount applied item by item to the total prices calculated in the prior linee
-- Order results by order_id
-- EXAMPLE 
-- 1615 rows reutrned
-- first row
# NAME, ORDER_ID, TOTAL_PRICE_BEFORE_DISCOUT, TOTAL_DISCOUNT
# 'Johnathan Velazquez', '1', '11397.94', '1166.89'

SELECT 
	CONCAT(first_name, ' ', last_name) AS NAME, order_id AS ORDER_ID, 
    (SELECT ROUND(SUM(quantity*list_price),2) FROM order_items WHERE (orders.order_id = order_items.order_id)) AS TOTAL_PRICE_BEFORE_DISCOUT,
    (SELECT ROUND(SUM(quantity*list_price*(discount)),2) FROM order_items WHERE (orders.order_id = order_items.order_id)) AS TOTAL_DISCOUNT
FROM
	customers, orders
WHERE
	customers.customer_id = orders.customer_id
GROUP BY
	ORDER_ID, TOTAL_PRICE_BEFORE_DISCOUT, TOTAL_DISCOUNT
ORDER BY
	order_id ASC;
    
