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
    order user id asc */



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
    
    
    
/* Premium vs Freemium ----------------------------------------------------------------
https://platform.stratascratch.com/coding/10300-premium-vs-freemium?code_type=3
- Find the total number of downloads for paying and non-paying users by date. Include only 
records where non-paying customers have more downloads than paying customers. The output 
should be sorted by earliest date first and contain 3 columns date, non-paying downloads, 
paying downloads. */

WITH users AS (
    SELECT u.user_id AS user_id, u.acc_id AS acc_id, a.paying_customer, d.date, d.downloads
    FROM ms_user_dimension u
    LEFT JOIN ms_acc_dimension a
        ON u.acc_id = a.acc_id
    LEFT JOIN ms_download_facts d
        ON u.user_id = d.user_id
)
SELECT date, SUM(CASE WHEN paying_customer = "no" THEN downloads ELSE 0 END) AS non_paying_downloads
    , SUM(CASE WHEN paying_customer = "yes" THEN downloads ELSE 0 END) AS paying_downloads
FROM users
GROUP BY date
HAVING non_paying_downloads > paying_downloads
ORDER BY date;


/*  Notes:
    output: date, non-playing downloads, paying downloads
        total number for both
        include only rows WHERE non-paying customers > paying customers downloads
        sorted by date ASC */



/* Top 5 States With 5 Star Businesses ------------------------------------------------
https://platform.stratascratch.com/coding/10046-top-5-states-with-5-star-businesses?code_type=3
- Find the top 5 states with the most 5 star businesses. Output the state name along 
with the number of 5-star businesses and order records by the number of 5-star businesses 
in descending order. In case there are ties in the number of businesses, return all the 
unique states. If two states have the same result, sort them in alphabetical order. */

WITH yb AS (
    SELECT state, five_star_counts, RANK() OVER (ORDER BY five_star_counts DESC) AS d_rank
    FROM (
        SELECT state, COUNT(stars) AS five_star_counts
        FROM yelp_business
        WHERE stars = 5
        GROUP BY state
    ) temp_yelp
)
SELECT state, five_star_counts
FROM yb
WHERE d_rank <= 5
ORDER BY five_star_counts DESC, state;


/* Notes:
    output: state name, # of 5-star businesses 
        order records by # of 5 star businesses DESC
        Top 5 states w/ most 5 star businesses 
            Same # of businesses -> return all unique states
            Two states with the same result - Sort state name ASC */
            
            

/* Counting Instances in Text ---------------------------------------------------------
https://platform.stratascratch.com/coding/9814-counting-instances-in-text?code_type=3
- Find the number of times the words 'bull' and 'bear' occur in the contents. We're 
counting the number of times the words occur so words like 'bullish' should not be 
included in our count.
Output the word 'bull' and 'bear' along with the corresponding number of occurrences. */

WITH RECURSIVE cte(filename, contents, n, summ) AS (
    SELECT filename, contents
    , 1 AS n
    , SUBSTRING_INDEX(SUBSTRING_INDEX(contents, " ", 1), " ", -1)
    FROM google_file_store 
    WHERE contents IS NOT NULL
UNION ALL
    SELECT filename, contents
    , n+1
    , SUBSTRING_INDEX(SUBSTRING_INDEX(contents, " ", n+1), " ", -1)
    FROM cte
    WHERE n < 1000
)
SELECT "bull" AS word, COUNT(*) AS count
FROM cte
WHERE summ = "Bull"
UNION ALL
SELECT "bear" AS word, COUNT(*) AS count
FROM cte
WHERE summ = "Bear";



/* City With Most Amenities -----------------------------------------------------------
https://platform.stratascratch.com/coding/9633-city-with-most-amenities?code_type=3
- You're given a dataset of searches for properties on Airbnb. For simplicity, let's 
say that each search result (i.e., each row) represents a unique host. Find the city 
with the most amenities across all their host's properties. Output the name of the city. */

WITH asd AS (
    SELECT city, SUM(LENGTH(amenities) - LENGTH(REPLACE(amenities, ",",""))+1) AS a_count
    FROM airbnb_search_details
    GROUP BY city
)
SELECT city 
FROM asd
LIMIT 1;



/* Host Popularity Rental Prices ------------------------------------------------------
https://platform.stratascratch.com/coding/9632-host-popularity-rental-prices?code_type=3
- You’re given a table of rental property searches by users. The table consists of search 
results and outputs host information for searchers. Find the minimum, average, maximum 
rental prices for each host’s popularity rating. The host’s popularity rating is defined as below:
	0 reviews: New
	1 to 5 reviews: Rising
	6 to 15 reviews: Trending Up
	16 to 40 reviews: Popular
	more than 40 reviews: Hot
Tip: The id column in the table refers to the search ID. You'll need to create your own host_id 
by concating price, room_type, host_since, zipcode, and number_of_reviews.
Output host popularity rating and their minimum, average and maximum rental prices. */

WITH r AS (
    SELECT CONCAT_WS("_", price, room_type, host_since, zipcode, number_of_reviews) AS host_id
        , price
        , CASE WHEN number_of_reviews = 0 THEN "New"
            WHEN number_of_reviews BETWEEN 1 AND 5 THEN "Rising"
            WHEN number_of_reviews BETWEEN 6 AND 15 THEN "Trending Up"
            WHEN number_of_reviews BETWEEN 16 AND 40 THEN "Popular"
            WHEN number_of_reviews > 40 THEN "Hot"
            END AS host_popularity
    FROM airbnb_host_searches
    GROUP BY host_id
)
SELECT host_popularity, MIN(price) AS minimum, AVG(price) AS average, MAX(price) AS maximum
FROM r
GROUP BY host_popularity;



/* Cookbook Recipes -------------------------------------------------------------------
https://platform.stratascratch.com/coding/2089-cookbook-recipes?code_type=3
- You are given the table with titles of recipes from a cookbook and their page 
numbers. You are asked to represent how the recipes will be distributed in the book.
Produce a table consisting of three columns: left_page_number, left_title and right_title. 
The k-th row (counting from 0), should contain the number and the title of the page with 
the number 2×k2×k in the first and second columns respectively, and the title of the page 
with the number 2×k+12×k+1 in the third column.
Each page contains at most 1 recipe. If the page does not contain a recipe, the appropriate 
cell should remain empty (NULL value). Page 0 (the internal side of the front cover) is 
guaranteed to be empty. */

WITH RECURSIVE c AS (
    SELECT 0 AS k
    UNION ALL
    SELECT k+2
    FROM c
    WHERE k+2 < (SELECT MAX(page_number) FROM cookbook_titles)
)
SELECT c.k, c2.title, c3.title
FROM c
LEFT JOIN cookbook_titles c2
    ON c.k = c2.page_number
LEFT JOIN cookbook_titles c3
    ON c.k = c3.page_number -1;
