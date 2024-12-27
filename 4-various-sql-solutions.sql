-- SQL query solutions from a variety of sources

/* Kelly's 3rd Purchase ---------------------------------------------------------------
https://www.analystbuilder.com/questions/kellys-3rd-purchase-kFaIE
- Write a query to select the 3rd transaction for each customer that received that discount. 
Output the customer id, transaction id, amount, and the amount after the discount as "discounted_amount".  */

SELECT customer_id, transaction_id, amount, ROUND(amount * 0.67, 2) AS discounted_amount
FROM (
  SELECT *, DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY transaction_id) AS r 
  FROM purchases 
) d 
WHERE r = 3
ORDER BY customer_id;



/* Temperature Fluctuations -----------------------------------------------------------
https://www.analystbuilder.com/questions/temperature-fluctuations-ftFQu
- Write a query to find all dates with higher temperatures compared to the previous dates (yesterday).
Order dates in ascending order.  */

SELECT *
FROM (
	SELECT (CASE WHEN temperature > LAG(temperature) OVER (ORDER BY date) THEN `date` END) AS higher_temp_days 
	FROM temperatures   
) t
WHERE higher_temp_days IS NOT NULL;



/* Cake vs Pie ------------------------------------------------------------------------
https://www.analystbuilder.com/questions/cake-vs-pie-rSDbF
- Write a query to report the difference between the number of Cakes and Pies sold each day.
Output should include the date sold, the difference between cakes and pies, 
and which one sold more (cake or pie). The difference should be a positive number.
Return the result table ordered by Date_Sold.
Columns in output should be date_sold, difference, and sold_more.  */

WITH des2 AS (
  SELECT date_sold, product, IFNULL(amount_sold, 0) AS amount_sold
  FROM desserts
)
SELECT c.date_sold, ABS(c.amount_sold - p.amount_sold) AS difference, 
  CASE WHEN c.amount_sold > p.amount_sold THEN 'Cake' WHEN c.amount_sold < p.amount_sold THEN 'Pie' END AS sold_more
FROM des2 c
LEFT JOIN des2 p
  ON c.date_sold = p.date_sold AND p.product = 'Pie'
WHERE c.product = 'Cake'
ORDER BY c.date_sold;



/* THE PADS ------------------------------------------------------------------------------------
https://www.hackerrank.com/challenges/the-pads/problem?isFullScreen=true
- Generate the following two result sets:
1. Query an alphabetically ordered list of all names in OCCUPATIONS, immediately followed 
	by the first letter of each profession as a parenthetical (i.e.: enclosed in parentheses). 
    For example: AnActorName(A), ADoctorName(D), AProfessorName(P), and ASingerName(S).

2. Query the number of ocurrences of each occupation in OCCUPATIONS. Sort the occurrences 
	in ascending order, and output them in the following format:
		"There are a total of [occupation_count] [occupation]s."
    where [occupation_count] is the number of occurrences of an occupation in OCCUPATIONS 
    and [occupation] is the lowercase occupation name. If more than one Occupation has the 
    same [occupation_count], they should be ordered alphabetically.
*/

SELECT CONCAT(Name, "(", LEFT(Occupation,1), ")") AS Name_occ
FROM OCCUPATIONS
ORDER BY Name;

SELECT CONCAT("There are a total of ", COUNT(Occupation)," ", LOWER(Occupation),"s.") AS Occ
FROM OCCUPATIONS
GROUP BY Occupation
ORDER BY Occ ASC, Occupation;