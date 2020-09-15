-- 8. Each store decides to give away free coupons to the customers 
-- who have ordered items from their store more than once. 
-- Retrieve STORE_NAME, CUSTOMER_NAME, NUM_ORDERS
-- CUSTOMER_NAME includes both first and last name appended with with a space character in between. 
-- Only keep the store-customer pairs where more than one order has been made.
-- Sort the results by store name alphabetic, then in decreasing order of NUM_ORDERS, 
-- and alphabetic by last name in the case of ties..
-- EXAMPLE
-- 132 rows returned
-- first row
# STORE_NAME, CUSTOMER_NAME, NUM_ORDERS
# 'Baldwin Bikes', 'Genoveva Baldwin', '3'

SELECT 
	store_name AS STORE_NAME, CONCAT(first_name, ' ', last_name) AS CUSTOMER_NAME, COUNT(orders.customer_id = customers.customer_id) AS NUM_ORDERS
FROM
	stores, customers, orders
WHERE
	customers.customer_id = orders.customer_id AND orders.store_id = stores.store_id
GROUP BY
	customers.customer_id, store_name
HAVING
	NUM_ORDERS > 1
ORDER BY
	store_name ASC, NUM_ORDERS DESC, last_name ASC;