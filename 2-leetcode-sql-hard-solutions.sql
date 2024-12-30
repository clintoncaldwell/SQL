-- Leetcode SQL Hard Difficulty Solutions

/*  185. Department Top Three Salaries ------------------------------------------------------------------------
https://leetcode.com/problems/department-top-three-salaries?envType=study-plan-v2&envId=top-sql-50
- A company's executives are interested in seeing who earns the most money in each of the company's departments. 
A high earner in a department is an employee who has a salary in the top three unique salaries for that department.
Write a solution to find the employees who are high earners in each of the departments. */

SELECT Department, Employee, Salary
FROM (
    SELECT d.name AS Department, e.name AS Employee, salary AS Salary,
    DENSE_RANK() OVER (PARTITION BY departmentId ORDER BY salary DESC) AS d_rank
    FROM Employee e
    LEFT JOIN Department d
        ON e.departmentId = d.id
) e
WHERE d_rank <= 3
ORDER BY Department, salary DESC;



/* 601. Human Traffic of Stadium -------------------------------------------------------
https://leetcode.com/problems/human-traffic-of-stadium?envType=problem-list-v2&envId=database
- Write a solution to display the records with three or more rows with consecutive id's, 
and the number of people is greater than or equal to 100 for each.
Return the result table ordered by visit_date in ascending order.  */

SELECT *
FROM Stadium
WHERE id IN (
    SELECT (LEAD(id) OVER (ORDER BY id) = id+1 AND (LEAD(id,2) OVER (ORDER BY id) = id+2 OR LAG(id) OVER (ORDER BY id) = id-1)
        OR (LAG(id) OVER (ORDER BY id) = id-1 AND LAG(id,2) OVER (ORDER BY id) = id-2)) 
        * id AS id
    FROM Stadium
    WHERE people >= 100
);
    


/* 262. Trips and Users ----------------------------------------------------------------
https://leetcode.com/problems/trips-and-users?envType=problem-list-v2&envId=database
- The cancellation rate is computed by dividing the number of canceled (by client or driver) 
requests with unbanned users by the total number of requests with unbanned users on that day.
Write a solution to find the cancellation rate of requests with unbanned users 
(both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03". 
Round Cancellation Rate to two decimal points.  */

WITH uid AS (
    SELECT users_id
    FROM Users
    WHERE banned = "No" AND role != 'partner'
)
SELECT request_at AS Day, 
    ROUND( SUM(CASE WHEN status != 'completed' THEN 1 ELSE 0 END) / COUNT(*) ,2) AS 'Cancellation Rate'
FROM Trips
WHERE client_id IN (TABLE uid) AND driver_id IN (TABLE uid)
    AND request_at BETWEEN "2013-10-01" AND "2013-10-03"
GROUP BY Day;



/*  3374. First Letter Capitalization II ------------------------------------------------------------------------
https://leetcode.com/problems/first-letter-capitalization-ii?envType=problem-list-v2&envId=database
- Write a solution to transform the text in the content_text column by applying the following rules:
    Convert the first letter of each word to uppercase and the remaining letters to lowercase
    Special handling for words containing special characters:
        - For words connected with a hyphen -, both parts should be capitalized (e.g., top-rated → Top-Rated)
    All other formatting and spacing should remain unchanged 
Return the result table that includes both the original content_text and the modified text following the above rules. */

WITH RECURSIVE cte(n, content_id, content_text, split_text) AS (
    SELECT 1
        , content_id, content_text
        , SUBSTRING_INDEX(LOWER(content_text)," ", 1)
    FROM user_content
    UNION ALL
    SELECT n+1
        , content_id, content_text
        , SUBSTRING_INDEX(SUBSTRING_INDEX(LOWER(content_text)," ", n+1)," ", -1)
    FROM cte 
    WHERE n < 100 AND LENGTH(SUBSTRING_INDEX(content_text," ", n)) != LENGTH(content_text)
)
SELECT content_id, content_text AS original_text
    , TRIM(REPLACE(GROUP_CONCAT(
    CONCAT(UPPER(LEFT(split_text, 1)),SUBSTRING(split_text, 2, LENGTH(split_text)-1))
    ORDER BY n), ",", " ")) AS converted_text
FROM (
    SELECT n, content_id, content_text
    , CASE WHEN LOCATE("-", split_text)
        THEN CONCAT( LEFT(split_text, LOCATE("-", split_text))
        , UPPER(SUBSTR(split_text, LOCATE("-", split_text)+1, 1))
        , SUBSTR(split_text, LOCATE("-", split_text)+2, LENGTH(split_text)-LOCATE("-", split_text)+2)
        )
        ELSE split_text
    END AS split_text
    FROM cte
) t
GROUP BY content_id;