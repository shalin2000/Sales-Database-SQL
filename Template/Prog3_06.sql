-- 6.  For each store, report the Average turnaround (time from order to shipment)
-- Retrieve the STORE_NAME, AVG_TURNAROUND ordered by the fastest stores first, alphabetic in the case of a tie.
-- EXAMPLE
# STORE_NAME, AVG_TURNAROUND
# 'Rowlett Bikes', '1.9203'
# 'Baldwin Bikes', '1.9766'
# 'Santa Cruz Bikes', '2.0399'

SELECT 
	store_name AS STORE_NAME, AVG(DATEDIFF(shipped_date, order_date)) AS AVG_TURNAROUND
FROM
	stores, orders
WHERE
	stores.store_id = orders.store_id
GROUP BY
	store_name
ORDER BY
	AVG_TURNAROUND ASC, store_name ASC;