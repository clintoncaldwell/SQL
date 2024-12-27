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