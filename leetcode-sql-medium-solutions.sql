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



-- ---------------------------------------------------------------------------------------------