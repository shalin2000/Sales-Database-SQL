-- 1. Generate a table containing nicely formatted customer information.
-- Retrieve the name, address and contact details of the customer 
-- as NAME, ADDRESS, CONTACT_DETAILS, ORDER_ID, ordered by last name. 
-- NAME includes both first and last name appended with with a space character in between. 
-- ADDRESS is calculated in the following way: <street> <city>, <state>, <zip_code>. 
-- CONTACT_DETAILS contains the string as: "Email: <email>, Phone: <phone>". 
-- If either of the email or the phone of the customer is null string, replace it with the string "N/A".
-- EXAMPLE 
-- 1445 rows returned
-- first row
# NAME, ADDRESS, CONTACT_DETAILS
#'Penny Acevedo', '318 Mulberry Drive  Ballston Spa, NY, 12020', 'Email: penny.acevedo@yahoo.com, Phone: N/A'

SELECT 
	CONCAT(first_name, ' ', last_name) AS NAME, CONCAT(street, city, ', ', state, ', ', zip_code) AS ADDRESS, CONCAT('Email: ', IFNULL(email, 'N/A'), ', ' ,'Phone: ', IFNULL(phone, 'N/A')) AS CONTACT_DETAILS 
FROM 
	customers
ORDER BY 
	last_name ASC, first_name ASC;


-- 2. Find the contact information for a particular customer.
-- Retrieve the name, address and contact details of the customer 
-- for the order_id stored in @oid as NAME, ADDRESS, CONTACT_DETAILS, ORDER_ID. 
-- Format is the same as question one, just output for a single order instead of all customers.
-- NAME includes both first and last name appended with with a space character in between. 
-- ADDRESS is calculated in the following way: <street> <city>, <state>, <zip_code>. 
-- CONTACT_DETAILS contains the string as: "Email: <email>, Phone: <phone>". 
-- If either of the email or the phone of the customer is null string, replace it with the string "N/A".
-- EXAMPLE 
-- input: set @oid = 5
# NAME, ADDRESS, CONTACT_DETAILS
# 'Arla Ellis', '127 Crescent Ave.  Utica, NY, 13501', 'Email: arla.ellis@yahoo.com, Phone: N/A'

SELECT 
	CONCAT(first_name, ' ', last_name) AS NAME, CONCAT(street, city, ', ', state, ', ', zip_code) AS ADDRESS, CONCAT('Email: ', IFNULL(email, 'N/A'), ', ' ,'Phone: ', IFNULL(phone, 'N/A')) AS CONTACT_DETAILS 
FROM 
	customers, orders
WHERE
	@oid = orders.order_id AND orders.customer_id = customers.customer_id;


-- 3. Filter out only the active orders.
-- Since we want to optimize the delivery services, 
-- from the orders table retrieve all the orders with 'Pending' and 'Processing' status 
-- and return a table with fields ORDER_ID, STATUS, STORE_ZIPCODE, CUSTOMER_ZIPCODE, REQUIRED_DATE. 
-- Order the results by STORE_ZIPCODE (ascending) and then by REQUIRED_DATE (earliest first).
-- The order statuses are as follows
-- Pending: 1 
-- Processing: 2
-- Rejected: 3
-- Completed : 4
-- EXAMPLE
-- 186 rows returned
-- first row
# ORDER_ID, STATUS, STORE_ZIPCODE, CUSTOMER_ZIPCODE, REQUIRED_DATE
# '1432', '2', '11432', '11757', '2018-03-12'

SELECT 
	orders.order_id AS ORDER_ID, orders.order_status AS STATUS, stores.zip_code AS STORE_ZIPCODE, customers.zip_code AS CUSTOMER_ZIPCODE, orders.required_date AS REQUIRED_DATE
FROM
	orders, stores, customers
WHERE
	(orders.store_id = stores.store_id) AND (orders.customer_id = customers.customer_id) AND (orders.order_status = 1 OR orders.order_status = 2)
ORDER BY
	stores.zip_code ASC,
    orders.required_date ASC,
    orders.order_id ASC;


-- 4. Investigate how long it takes in general (average number of days) for an order to get completed (time from order to shipping). 
-- Calculate the value as AVG_DAYS.
-- note that the - operand may produce strange values for different months/years
-- EXAMPLE
# AVG_DAYS
# '1.9835'

SELECT 
	AVG(DATEDIFF(shipped_date, order_date)) AS AVG_DAYS
From
	orders;


-- 5. Based on the calculation in 4 (use the computed value, not a hard coded one),
-- return the orders which are in 'Pending' or 'Processing' states (question 3)
-- which are exceeding the average from the current date stored in @today
-- and may require expedited priority.
-- The table should return the columns 
-- ORDER_ID, DAYS_SINCE_ORDER
-- sorted starting from the longest DAYS_SINCE_ORDER. 
-- EXAMPLE
-- input: SET @today = '2018-03-21'
-- 22 rows returned
-- first row
# ORDER_ID, DAYS_SINCE_ORDER
# '1430', '11'

SELECT 
	order_id AS ORDER_ID , DATEDIFF(@today, order_date) AS DAYS_SINCE_ORDER
FROM
	orders
WHERE
	(orders.order_status = 1 OR orders.order_status = 2) AND (DATEDIFF(@today, order_date) > (SELECT AVG(DATEDIFF(shipped_date, order_date)) FROM orders))
ORDER BY
	DAYS_SINCE_ORDER DESC;



-- 6.  For each store, report the Average turnaround (time from order to shipment).
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


-- 7. For each store, list the percentage of orders which did not ship until after the required_date.
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


-- 8. Each store decides to give away free coupons to the customers 
-- who have ordered items from their store more than once. 
-- Retrieve STORE_NAME, CUSTOMER_NAME, NUM_ORDERS
-- CUSTOMER_NAME includes both first and last name appended with with a space character in between. 
-- Only keep the store-customer pairs where more than one order has been made.
-- Sort the results by store name alphabetic, then in decreasing order of NUM_ORDERS, 
-- and alphabetic by last name in the case of ties.
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


-- 9. List information about each order.
-- Retrieve NAME, ORDER_ID, TOTAL_PRICE_BEFORE_DISCOUT, TOTAL_DISCOUNT
-- NAME includes both first and last customer name appended with with a space character in between. 
-- TOTAL_PRICE_BEFORE_DISCOUNT is the number of items multiplied by the list prices of those items, added up over all items in the order
-- TOTAL_DISCOUNT is the sum of the discount applied item by item to the total prices calculated in the prior linee
-- Order results by order_id
-- EXAMPLE 
-- 1615 rows returned
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

