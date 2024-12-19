-- Leetcode SQL Medium Difficulty Solutions

/*  570. Managers with at Least 5 Direct Reports ----------------------------------------------------------------
https://leetcode.com/problems/managers-with-at-least-5-direct-reports?envType=study-plan-v2&envId=top-sql-50
- Write a solution to find managers with at least five direct reports. */

/* Process: 
Decided to use a subquery to first retrieve the managerId's of any Employee that
was counted at least 5 times as a manager to others. Then, using the WHERE clause 
to find the employee through their unique id. Finally, querying the name(s) of anyone
who's id was retrieved from the subquery, since they fulfilled all the necessary conditions. 
*/
SELECT name
FROM Employee
WHERE id IN (
    SELECT managerId
    FROM Employee
    GROUP BY managerId
    HAVING COUNT(managerId) >= 5 
);



/* 1934. Confirmation Rate ---------------------------------------------------------------------
https://leetcode.com/problems/confirmation-rate?envType=study-plan-v2&envId=top-sql-50
- Write a solution to find the confirmation rate of each user. */

/* Process:
Made a subquery inside the SELECT statement because I needed to query a value that
needed a WHERE clause after aggregation. 
*/
SELECT s.user_id, 
ROUND(
    IFNULL((
        SELECT COUNT(c2.action)
        FROM Confirmations c2
        WHERE c2.action = "confirmed" AND s.user_id = c2.user_id
    ) / COUNT(c.user_id),0), 2
) AS confirmation_rate
FROM Signups s
LEFT JOIN Confirmations c
    ON s.user_id = c.user_id
GROUP BY s.user_id;



/* 1193. Monthly Transactions I ----------------------------------------------------------------
https://leetcode.com/problems/monthly-transactions-i?envType=study-plan-v2&envId=top-sql-50
- Write an SQL query to find for each month and country, the number of transactions and their 
total amount, the number of approved transactions and their total amount. */

/* Process:
Originally planned to perform a subquery to retrieve such as approved_count, but then
realized it would be more efficient to use a case statement in the select statement. Since
conditional statements such as "state = 'approved'" returns 1 or 0, I multiplied the result
by the amount within the SUM aggregate, allowing me to get the sum of the column with entries
following a certain condition without creating a subquery. Finally, since both month and 
country columns will possibly have duplicate values, e.g. (January, US) & (January, CA) or 
(April, FR) & (May, FR), I grouped by the concatenation of both values.
*/
SELECT 
    LEFT(trans_date,7) AS "month", 
    country, 
    COUNT("month") AS trans_count, 
    COUNT(case when state = "approved" then 1 else NULL end) AS approved_count, 
    SUM(amount) AS trans_total_amount, 
    SUM((state = "approved") * amount) AS approved_total_amount
FROM Transactions
GROUP BY CONCAT(month, country);



/* 1174. Immediate Food Delivery II ------------------------------------------------------------
https://leetcode.com/problems/immediate-food-delivery-ii?envType=study-plan-v2&envId=top-sql-50
- Write a solution to find the percentage of immediate orders in the first orders of all 
customers, rounded to 2 decimal places. */

SELECT ROUND(
    SUM(order_date = customer_pref_delivery_date)* 100 / COUNT(*)
    ,2) AS immediate_percentage
FROM Delivery
WHERE (customer_id, order_date) IN (
    SELECT customer_id, MIN(order_date)
    FROM Delivery
    GROUP BY customer_id
    );



/* 550. Game Play Analysis IV ------------------------------------------------------------------
https://leetcode.com/problems/game-play-analysis-iv?envType=study-plan-v2&envId=top-sql-50
- Write a solution to report the fraction of players that logged in again on the day 
after the day they first logged in, rounded to 2 decimal places. In other words, you 
need to count the number of players that logged in for at least two consecutive days 
starting from their first login date, then divide that number by the total number of players. */

SELECT ROUND( COUNT(a2_event_date) / SUM(IF(a2_event_date IS NULL, 1, 1)) , 2) AS fraction
FROM (
    SELECT a2_event_date
    FROM (
        SELECT a1.player_id AS a1_id, a1.event_date AS a1_event_date, a2.event_date AS a2_event_date
        FROM Activity a1
        LEFT JOIN Activity a2
        ON a1.player_id = a2.player_id
        AND a1.event_date = DATE_SUB(a2.event_date, INTERVAL 1 DAY)
        GROUP BY a1.player_id , a1.event_date
        HAVING MIN(a1_event_date)
        ORDER BY a1.player_id, a1.event_date ASC
    ) a3
    GROUP BY a1_id
) a4;



/* 1070. Product Sales Analysis III -------------------------------------------------------------
https://leetcode.com/problems/product-sales-analysis-iii?envType=study-plan-v2&envId=top-sql-50
- Write a solution to select the product id, year, quantity, and price for the first year
of every product sold. */

SELECT product_id, year AS first_year, quantity, price
FROM Sales
WHERE (product_id, year) IN (
    SELECT product_id, MIN(year)
    FROM Sales
    GROUP BY product_id
);



/* 1045. Customers Who Bought All Products -----------------------------------------------------
https://leetcode.com/problems/customers-who-bought-all-products?envType=study-plan-v2&envId=top-sql-50
- Write a solution to report the customer ids from the Customer table that bought all the 
products in the Product table. */

SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (
    SELECT COUNT(product_key)
    FROM Product
);



/* 180. Consecutive Numbers --------------------------------------------------------------------
https://leetcode.com/problems/consecutive-numbers?envType=study-plan-v2&envId=top-sql-50
- Find all numbers that appear at least three times consecutively. */

SELECT a.num AS ConsecutiveNums
FROM Logs a 
LEFT JOIN Logs b
    ON a.id = b.id -1
LEFT JOIN Logs c
    ON a.id = c.id -2
WHERE a.num = b.num AND a.num = c.num
GROUP BY a.num;



/* 1164. Product Price at a Given Date ---------------------------------------------------------
https://leetcode.com/problems/product-price-at-a-given-date?envType=study-plan-v2&envId=top-sql-50
- Write a solution to find the prices of all products on 2019-08-16. 
Assume the price of all products before any change is 10. */

/* Process:
Goal: Find current prices on 2019-08-16
- Filter the entries where date <= to 2019-08-16
    - Then find the MAX(date) of this subgroup
- Join the two tables through the primary key, product_id
    - Filter the entries using the date results from the previous table
		- If the date is NULL, then set the price to 10
*/
SELECT DISTINCT p1.product_id, 
    CASE WHEN p2.target_date IS NOT NULL THEN p1.new_price ELSE 10 END AS price
FROM products p1
LEFT JOIN (
    SELECT product_id, MAX(change_date) AS target_date
    FROM products
    WHERE change_date <= '2019-08-16'
    GROUP BY product_id
) p2 
ON p1.product_id = p2.product_id
WHERE (p1.product_id, p1.change_date) = (p2.product_id, p2.target_date)
    OR ISNULL(p2.target_date);



/* 1204. Last Person to Fit in the Bus ---------------------------------------------------------
https://leetcode.com/problems/last-person-to-fit-in-the-bus?envType=study-plan-v2&envId=top-sql-50
- Write a solution to find the person_name of the last person that can fit on the bus without 
exceeding the weight limit. The test cases are generated such that the first person does not 
exceed the weight limit.
Note that only one person can board the bus at any given turn. */

SELECT person_name
FROM (
    SELECT person_name, turn, (
		SELECT SUM(weight) 
		FROM Queue q2
		WHERE q1.turn >= q2.turn
	) AS total_weight
	FROM Queue q1
	HAVING total_weight <= 1000
    ORDER BY turn DESC
    LIMIT 1
) q3;



-- ---------------------------------------------------------------------------------------------