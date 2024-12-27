-- StrataScratch SQL Hard Difficulty Solutions

/* Retention Rate ---------------------------------------------------------------------
https://platform.stratascratch.com/coding/2053-retention-rate?code_type=3
- Find the monthly retention rate of users for each account separately for Dec 2020 and Jan 2021. 
Retention rate is the percentage of active users an account retains over a given period of time. 
In this case, assume the user is retained if he/she stays with the app in any future months. 
For example, if a user was active in Dec 2020 and has activity in any future month, consider them 
retained for Dec. You can assume all accounts are present in Dec 2020 and Jan 2021. 

Your output should have the account ID and the Jan 2021 retention rate divided by Dec 2020 retention rate.  */

WITH ev AS (
    SELECT account_id, user_id
        , CASE WHEN DATE_FORMAT(MAX(date), "%Y-%m") > "2020-12" THEN 1 ELSE 0 END  AS retained_dec_2020
        , CASE WHEN DATE_FORMAT(MAX(date), "%Y-%m") > "2021-01" THEN 1 ELSE 0 END  AS retained_jan_2021
    FROM sf_events
    GROUP BY user_id
)
SELECT account_id
    , (SUM(retained_jan_2021) / COUNT(account_id)) / (SUM(retained_dec_2020) / COUNT(account_id)) AS "Retention Rate"
FROM ev
GROUP BY account_id;


/* Notes: 
retention rate of users
    on each account, separately for both dec 2020 and jan 2021
    retention rate = percentage of active/retained users in an individual account
        retained = active in any future months
output: 'account ID', (Jan 2021 / Dec 2020 retention rates) */



/* Popularity Percentage --------------------------------------------------------------
https://platform.stratascratch.com/coding/10284-popularity-percentage?code_type=3
- Find the popularity percentage for each user on Meta/Facebook. The dataset contains two columns, 
user1 and user2, which represent pairs of friends. Each row indicates a mutual friendship between 
user1 and user2, meaning both users are friends with each other. A user's popularity percentage is 
calculated as the total number of friends they have (counting connections from both user1 and user2 
columns) divided by the total number of unique users on the platform. Multiply this value by 100 to 
express it as a percentage.

Output each user along with their calculated popularity percentage. 
The results should be ordered by user ID in ascending order. */

WITH all_users AS (
    SELECT user1 AS user FROM facebook_friends
    UNION ALL
    SELECT user2 FROM facebook_friends
)
SELECT user AS "User ID", COUNT(*) / (
        SELECT COUNT(*) FROM facebook_friends
    ) * 100 AS "Popularity Percentage" 
FROM all_users
GROUP BY user
ORDER BY user;


/* Notes:
    popularity percentage = (user's total number of friends / total number of unique users) * 100
        count from both columns
    output: user id, popularity percentage
    order user id asc
*/



/* Monthly Percentage Difference ------------------------------------------------------
https://platform.stratascratch.com/coding/10319-monthly-percentage-difference?code_type=3
- Given a table of purchases by date, calculate the month-over-month percentage change in revenue. 
The output should include the year-month date (YYYY-MM) and percentage change, rounded to the 
2nd decimal point, and sorted from the beginning of the year to the end of the year.
The percentage change column will be populated from the 2nd month forward and can be calculated 
as ((this month's revenue - last month's revenue) / last month's revenue)*100. */

WITH ym AS (
    SELECT DATE_FORMAT(created_at, "%Y-%m") AS yr_month, SUM(value) AS revenue  
    FROM sf_transactions
    GROUP BY yr_month
)
SELECT yr_month AS 'year_month', ROUND(((revenue - LAG(revenue) OVER (ORDER BY yr_month)) 
    / LAG(revenue) OVER (ORDER BY yr_month)) * 100, 2) AS percentage_change
FROM ym
ORDER BY yr_month;



/* Top Percentile Fraud ---------------------------------------------------------------
https://platform.stratascratch.com/coding/10303-top-percentile-fraud?code_type=3
- We want to identify the most suspicious claims in each state. We'll consider the top 5 
percentile of claims with the highest fraud scores in each state as potentially fraudulent.
Your output should include the policy number, state, claim cost, and fraud score. */

SELECT policy_num, state, claim_cost, fraud_score
FROM (
    SELECT policy_num, state, claim_cost, fraud_score
        , PERCENT_RANK() OVER (PARTITION BY state ORDER BY fraud_score DESC) AS prc_rank
    FROM fraud_score
) f
WHERE prc_rank <= 0.05;

/* 	Notes:
	output: policy number, state, claim cost, fraud score
    top 5 percentile - of highest fraud scores in EACH state - PERCENT_RANK() w/ partition */