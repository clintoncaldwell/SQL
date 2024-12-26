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



/* 1907. Count Salary Categories ---------------------------------------------------------------
https://leetcode.com/problems/count-salary-categories?envType=study-plan-v2&envId=top-sql-50
- Write a solution to calculate the number of bank accounts for each salary category. The salary categories are:
    "Low Salary": All the salaries strictly less than $20000.
    "Average Salary": All the salaries in the inclusive range [$20000, $50000].
    "High Salary": All the salaries strictly greater than $50000.
The result table must contain all three categories. If there are no accounts in a category, return 0. */

SELECT 'Low Salary' AS category, SUM(income<20000) AS accounts_count FROM Accounts
UNION ALL
SELECT 'Average Salary' AS category, SUM(income>=20000 AND income<=50000) AS accounts_count FROM Accounts
UNION ALL
SELECT 'High Salary' AS category, SUM(income>50000) AS accounts_count FROM Accounts;



/* 626. Exchange Seats -------------------------------------------------------------------------
https://leetcode.com/problems/exchange-seats?envType=study-plan-v2&envId=top-sql-50
- Write a solution to swap the seat id of every two consecutive students. 
If the number of students is odd, the id of the last student is not swapped.
Return the result table ordered by id in ascending order. */

SELECT s.id,
CASE WHEN s2.student IS NOT NULL THEN s2.student ELSE s.student END AS student
FROM Seat s
LEFT JOIN Seat s2
    ON (CASE 
        WHEN s.id % 2
            THEN s.id = s2.id -1
        ELSE s.id = s2.id +1
        END
    );



/* 1341. Movie Rating --------------------------------------------------------------------------
https://leetcode.com/problems/movie-rating?envType=study-plan-v2&envId=top-sql-50
- Write a solution to:
    Find the name of the user who has rated the greatest number of movies. In case of a tie, 
    return the lexicographically smaller user name.
    Find the movie name with the highest average rating in February 2020. In case of a tie, 
    return the lexicographically smaller movie name. */

(
SELECT u.name AS results
FROM MovieRating mr2
LEFT JOIN Users u
    ON mr2.user_id = u.user_id
GROUP BY mr2.user_id
ORDER BY COUNT(mr2.user_id) DESC, u.name
LIMIT 1
)
UNION ALL
(
SELECT m.title AS results
FROM MovieRating mr
LEFT JOIN Movies m
    ON mr.movie_id = m.movie_id
WHERE DATE_FORMAT(created_at, "%Y-%m") = '2020-02'
GROUP BY mr.movie_id
ORDER BY AVG(mr.rating) DESC, m.title
LIMIT 1
);


/* 3220. Odd and Even Transactions -------------------------------------------------------------
https://leetcode.com/problems/odd-and-even-transactions?envType=problem-list-v2&envId=database
- Write a solution to find the sum of amounts for odd and even transactions for each day. 
If there are no odd or even transactions for a specific date, display as 0.
Return the result table ordered by transaction_date in ascending order. */

SELECT transaction_date,
SUM(CASE WHEN (amount % 2) > 0 THEN amount ELSE 0 END) AS odd_sum, 
SUM(CASE WHEN (amount % 2) = 0 THEN amount ELSE 0 END) AS even_sum
FROM transactions
GROUP BY transaction_date
ORDER BY transaction_date;



/* 1393. Capital Gain/Loss ---------------------------------------------------------------------
https://leetcode.com/problems/capital-gainloss?envType=problem-list-v2&envId=database
- Write a solution to report the Capital gain/loss for each stock.
The Capital gain/loss of a stock is the total gain or loss after buying and selling the stock 
one or many times. Return the result table in any order. */

SELECT stock_name, 
    SUM(CASE WHEN operation = 'Buy' THEN price*-1 ELSE price END)
    AS capital_gain_loss
FROM Stocks
GROUP BY stock_name;



/* 1321. Restaurant Growth ---------------------------------------------------------------------
https://leetcode.com/problems/restaurant-growth?envType=problem-list-v2&envId=database
- You are the restaurant owner and you want to analyze a possible expansion 
(there will be at least one customer every day).
Compute the moving average of how much the customer paid in a seven days window 
(i.e., current day + 6 days before). average_amount should be rounded to two decimal places.
Return the result table ordered by visited_on in ascending order. */

WITH grp_c AS (
    SELECT customer_id, name, visited_on, SUM(amount) AS amount 
    FROM Customer
    GROUP BY visited_on
)
SELECT 
visited_on, 
(
    SELECT SUM(amount)
    FROM grp_c
    WHERE visited_on BETWEEN DATE_SUB(g.visited_on, INTERVAL 6 DAY) AND g.visited_on
) AS amount, 
(
    SELECT ROUND(AVG(amount),2)
    FROM grp_c
    WHERE visited_on BETWEEN DATE_SUB(g.visited_on, INTERVAL 6 DAY) AND g.visited_on
) AS average_amount
FROM grp_c g
ORDER BY visited_on
LIMIT 1000 OFFSET 6;



/* 602. Friend Requests II: Who Has the Most Friends --------------------------------------------
https://leetcode.com/problems/friend-requests-ii-who-has-the-most-friends?envType=study-plan-v2&envId=top-sql-50
- Write a solution to find the people who have the most friends and the most friends number.
The test cases are generated so that only one person has the most friends. */

WITH sub AS(
    SELECT requester_id AS id
    FROM RequestAccepted 
    UNION ALL
    SELECT accepter_id 
    FROM RequestAccepted 
)
SELECT *
FROM ( 
    SELECT id,
    COUNT(id) AS num
    FROM sub
    GROUP BY id
) s
ORDER BY num DESC
LIMIT 1;



/* 585. Investments in 2016 --------------------------------------------------------------------
https://leetcode.com/problems/investments-in-2016?envType=study-plan-v2&envId=top-sql-50
- Write a solution to report the sum of all total investment values in 2016 tiv_2016, for all policyholders who:
    - have the same tiv_2015 value as one or more other policyholders, and
    - are not located in the same city as any other policyholder (i.e., the (lat, lon) attribute pairs must be unique).
Round tiv_2016 to two decimal places. */

SELECT ROUND(SUM(tiv_2016),2) AS tiv_2016
FROM (
    SELECT pid, tiv_2015, tiv_2016
    FROM Insurance
    GROUP BY lat, lon
    HAVING COUNT(lat) = 1 OR COUNT(lon) = 1 
) i
WHERE pid NOT IN (
    SELECT pid
    FROM Insurance
    GROUP BY tiv_2015
    HAVING COUNT(tiv_2015) = 1
);



/* 176. Second Highest Salary ------------------------------------------------------------------
https://leetcode.com/problems/second-highest-salary?envType=study-plan-v2&envId=top-sql-50
- Write a solution to find the second highest distinct salary from the Employee table. 
If there is no second highest salary, return null  */

SELECT salary AS SecondHighestSalary 
FROM (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS `Rank`
    FROM Employee 
) e
WHERE `Rank` = 2
UNION
SELECT NULL
LIMIT 1;



/* 184. Department Highest Salary --------------------------------------------------------------
https://leetcode.com/problems/department-highest-salary?envType=problem-list-v2&envId=database
- Write a solution to find employees who have the highest salary in each of the departments.
Return the result table in any order.  */

SELECT Department, Employee, Salary
FROM (
    SELECT d.name AS Department, e.name AS Employee, salary AS Salary,
        DENSE_RANK() OVER (PARTITION BY d.name ORDER BY salary DESC) AS r
    FROM Employee e
    LEFT JOIN Department d
        ON e.departmentId = d.id
) e2
WHERE r = 1;



/* 178. Rank Scores ----------------------------------------------------------------------------
https://leetcode.com/problems/rank-scores?envType=problem-list-v2&envId=database
- Write a solution to find the rank of the scores. 
The ranking should be calculated according to the following rules:
    -The scores should be ranked from the highest to the lowest.
    -If there is a tie between two scores, both should have the same ranking.
    -After a tie, the next ranking number should be the next consecutive integer value. 
		In other words, there should be no holes between ranks.
Return the result table ordered by score in descending order.  */

SELECT score, 
    DENSE_RANK() OVER (ORDER BY score DESC) AS `rank`
FROM Scores;



/* 177. Nth Highest Salary ---------------------------------------------------------------------
https://leetcode.com/problems/nth-highest-salary?envType=problem-list-v2&envId=database
- Write a solution to find the nth highest salary from the Employee table. 
If there is no nth highest salary, return null.  */

CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
        SELECT DISTINCT salary
        FROM (
            SELECT *, DENSE_RANK() OVER (ORDER BY salary DESC) AS r
            FROM Employee
        ) e
        WHERE r = N
  );
END



/* 1158. Market Analysis I ---------------------------------------------------------------------
https://leetcode.com/problems/market-analysis-i?envType=problem-list-v2&envId=database
- Write a solution to find for each user, the join date and the number of 
orders they made as a buyer in 2019.  */

SELECT user_id AS buyer_id, join_date, COUNT(buyer_id) AS orders_in_2019
FROM Users u
LEFT JOIN Orders o
    ON u.user_id = o.buyer_id AND YEAR(order_date) = 2019
GROUP BY u.user_id;

    
    
/* 608. Tree Node ---------------------------------------------------------------------
https://leetcode.com/problems/tree-node?envType=problem-list-v2&envId=database
- Each node in the tree can be one of three types:
    "Leaf": if the node is a leaf node.
    "Root": if the node is the root of the tree.
    "Inner": If the node is neither a leaf node nor a root node.
Write a solution to report the type of each node in the tree.
Return the result table in any order.  */

WITH tree2 AS (
    SELECT t.id, t.p_id, COUNT(t2.p_id) AS c_id
    FROM Tree t
    LEFT JOIN Tree t2
        ON t.id = t2.p_id
    GROUP BY t.id
)
SELECT id,
    CASE WHEN p_id AND c_id THEN "Inner" WHEN p_id AND NOT c_id THEN "Leaf" ELSE "Root" END AS type
FROM tree2;

-- -----