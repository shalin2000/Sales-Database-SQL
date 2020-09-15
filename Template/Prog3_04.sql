-- 4. Investigate how long it takes in general (average number of days) 
-- for an order to get completed (time from order to shipping). 
-- Calculate the value as AVG_DAYS.
-- note that the - operand may produce strange values for different months/years
-- EXAMPLE
-- output:
# AVG_DAYS
# '1.9835'

SELECT 
	AVG(DATEDIFF(shipped_date, order_date)) AS AVG_DAYS
From
	orders
