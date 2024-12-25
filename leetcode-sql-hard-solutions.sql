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



/*  3374. First Letter Capitalization II ------------------------------------------------------------------------
https://leetcode.com/problems/first-letter-capitalization-ii?envType=problem-list-v2&envId=database
- Write a solution to transform the text in the content_text column by applying the following rules:
    Convert the first letter of each word to uppercase and the remaining letters to lowercase
    Special handling for words containing special characters:
        - For words connected with a hyphen -, both parts should be capitalized (e.g., top-rated → Top-Rated)
    All other formatting and spacing should remain unchanged 
Return the result table that includes both the original content_text and the modified text following the above rules. */

WITH RECURSIVE cte AS
(
    SELECT content_id, 
    content_text,
    CASE 
        WHEN LOCATE("-", SUBSTRING_INDEX(content_text ," ", 1) ) 
        THEN CONCAT(LEFT(
                CONCAT(LEFT(UPPER(SUBSTRING_INDEX(content_text ," ", 1) ),1),SUBSTR(LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(content_text ," ", 1) ," ", 1)),2))
            , LOCATE("-", SUBSTRING_INDEX(content_text ," ", 1) )), UPPER(SUBSTR(
                CONCAT(LEFT(UPPER(SUBSTRING_INDEX(content_text ," ", 1) ),1),SUBSTR(LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(content_text ," ", 1) ," ", 1)),2))
            , LOCATE("-", SUBSTRING_INDEX(content_text ," ", 1) )+1, 1)), SUBSTR(
                CONCAT(LEFT(UPPER(SUBSTRING_INDEX(content_text ," ", 1) ),1),SUBSTR(LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(content_text ," ", 1) ," ", 1)),2))
            , LOCATE("-", SUBSTRING_INDEX(content_text ," ", 1) )+2)
            )
        ELSE CONCAT(LEFT(UPPER(SUBSTRING_INDEX(content_text ," ", 1) ),1),SUBSTR(LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(content_text ," ", 1) ," ", 1)),2))
    END
    AS converted_text,
    1 AS cnt
    FROM user_content
    UNION 

    SELECT c.content_id,
    c.content_text,
    CONCAT_WS(" ", converted_text,
        CASE 
            WHEN LOCATE("-", SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1)) 
            THEN CONCAT(LEFT(
                    CONCAT(LEFT(UPPER(SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1)),1),SUBSTR(LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1)," ", 1)),2))
                , LOCATE("-", SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1))), UPPER(SUBSTR(
                    CONCAT(LEFT(UPPER(SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1)),1),SUBSTR(LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1)," ", 1)),2))
                , LOCATE("-", SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1))+1, 1)), SUBSTR(
                    CONCAT(LEFT(UPPER(SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1)),1),SUBSTR(LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1)," ", 1)),2))
                , LOCATE("-", SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1))+2)
            )
            ELSE CONCAT(LEFT(UPPER(SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1)),1),SUBSTR(LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1)," ", 1)),2))
    END
    ),
    cnt+1
    FROM cte c
    LEFT JOIN user_content u
    ON c.content_id = u.content_id
    WHERE converted_text != ""
        AND SUBSTRING_INDEX(SUBSTR(u.content_text, LENGTH(SUBSTRING_INDEX(u.content_text," ", cnt))+2) ," ", 1) != ""  
)
SELECT c1.content_id,
    c1.content_text AS original_text,
    MAX(c1.converted_text) AS converted_text
FROM cte c1
LEFT JOIN cte c2
ON c1.content_id = c2.content_id -1
GROUP BY c1.content_id;