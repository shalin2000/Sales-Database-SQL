-- 7. For each store, list the percentage of orders which did not ship until after the required_date
-- Retrieve the STORE_NAME, PERCENT_OVERDUE with the greatest first, alphabetic in the case of a tie.
-- EXAMPLE
# STORE_NAME, PERCENT_OVERDUE
# 'Santa Cruz Bikes', '29.3103'
# 'Baldwin Bikes', '27.8134'
# 'Rowlett Bikes', '20.1149'

SELECT 
	store_name AS STORE_NAME, (COUNT((orders.shipped_date > orders.required_date) or orders.shipped_date = NULL) / (COUNT(orders.required_date))) * 100 AS PERCENT_OVERDUE
FROM
	stores, orders
WHERE
	stores.store_id = orders.store_id 
GROUP BY
	store_name
ORDER BY
	PERCENT_OVERDUE DESC, store_name ASC;