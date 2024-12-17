-- Leetcode: SQL 50
-- https://leetcode.com/studyplan/top-sql-50/

/*  1757. Recyclable and Low Fat Products -------------------------------------
Write a solution to find the ids of products that are both low fat and recyclable. */

SELECT product_id
FROM Products
WHERE low_fats = 'Y' 
    AND recyclable = 'Y'; 



/*  584. Find Customer Referee -------------------------------------
Find the names of the customer that are not referred by the customer with id = 2. */

SELECT name
FROM Customer
WHERE IFNULL(referee_id, 0) != 2;



/* 595. Big Countries -------------------------------------
A country is big if:
    it has an area of at least three million (i.e., 3000000 km2), or
    it has a population of at least twenty-five million (i.e., 25000000).
Write a solution to find the name, population, and area of the big countries. */

SELECT name, population, area
FROM World
WHERE area >= 3000000 OR population >= 25000000;



/*  570. Managers with at Least 5 Direct Reports -------------------------------------
Write a solution to find managers with at least five direct reports. */

SELECT name
FROM Employee
WHERE id IN (
    SELECT managerId
    FROM Employee
    GROUP BY managerId
    HAVING COUNT(managerId) >= 5 
);



/* 1934. Confirmation Rate -------------------------------------
Write a solution to find the confirmation rate of each user. */

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








/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */



/*  1757. Recyclable and Low Fat Products -------------------------------------

Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order. */