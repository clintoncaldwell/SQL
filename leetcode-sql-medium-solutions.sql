-- Leetcode SQL Medium Difficulty Solutions

/*  570. Managers with at Least 5 Direct Reports -----------------------------------------------
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



-- ---------------------------------------------------------------------------------------------