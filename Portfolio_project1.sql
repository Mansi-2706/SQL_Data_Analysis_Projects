--1.) write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

WITH citywise_spend AS (
	SELECT city, SUM(amount) AS total_spend FROM [dbo].[credit_card_transactions$]
	GROUP BY city
),
total_spent AS (
	SELECT SUM(CAST(amount AS bigint)) AS total_amount FROM [dbo].[credit_card_transactions$]
)
SELECT top 5 citywise_spend.*, round((total_spend*1.0/total_amount)*100,2) AS percentage_contribution FROM citywise_spend, total_spent
ORDER BY total_spend DESC
;
/*
city	        total_spend	percentage_contribution
Greater Mumbai	576649011	21.96
Bengaluru	    571416976	21.76
Ahmedabad	    566995717	21.59
Delhi	        556323111	21.18
Bathinda	    1894944	    0.07
*/

--2.) write a query to print highest spend month and amount spent in that month for each card type

WITH CTE AS (
	SELECT card_type, 
	DATEPART(year, transaction_date) AS yt,
	DATEPART(month, transaction_date) AS mt,
	SUM(amount) AS total_spent
	FROM [dbo].[credit_card_transactions$]
	GROUP BY card_type, DATEPART(year, transaction_date), DATEPART(month, transaction_date)
)
SELECT * FROM (SELECT *, RANK() OVER (PARTITION BY card_type ORDER BY total_spent DESC) AS rn FROM CTE) a WHERE rn = 1

/*
card_type	yt	    mt	total_spent	 rn
Gold	    2015	1	37399181	 1
Platinum	2014	8	40440624	 1
Signature	2014	10	40175164	 1
Silver	    2015	3	41326242	 1
*/

--3.) write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

--we will be using running sum concept here (aggregation in windows function)

WITH cte AS (
	SELECT *, SUM(amount) OVER(PARTITION BY card_type ORDER BY transaction_date, transaction_id) AS total_spend
	FROM [dbo].[credit_card_transactions$]
)
SELECT * FROM (SELECT * , RANK() OVER (PARTITION BY card_type ORDER BY total_spend) AS rn FROM cte
WHERE total_spend >= 1000000) a WHERE rn = 1
/*
transaction_id	city	    transaction_date	      card_type	 exp_type	gender	amount	total_spend	rn
1522	        Delhi	    2013-10-04 00:00:00.000	  Gold	     Food	    M	    281924	1272624	    1
191	            Ahmedabad	2013-10-05 00:00:00.000	  Platinum	 Bills	    F	    612572	1239093	    1
73	            Delhi	    2013-10-04 00:00:00.000	  Signature	 Bills	    F	    550782	1285819	    1
7565	        Bengaluru	2013-10-04 00:00:00.000	  Silver	 Food	    F	    205179	1115582	    1
*/

--4.) write a query to find city which had lowest percentage spend for gold card type

WITH cte AS (
SELECT top 1 city, card_type, SUM(amount) AS amount,
SUM(CASE WHEN card_type = 'Gold' THEN amount END) AS gold_amount
FROM [dbo].[credit_card_transactions$]
GROUP BY city, card_type
)
SELECT city, SUM(gold_amount)*1.0/SUM(amount) AS gold_ratio
FROM cte
GROUP BY city
HAVING SUM(gold_amount) IS NOT NULL
--HAVING COUNT(gold_amount)>0 AND SUM(gold_amount)>0
ORDER BY gold_ratio;
/*
city	    gold_ratio
Achalpur	1
*/

--5) write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

WITH cte AS (
	SELECT city, exp_type, SUM(amount) AS total_amount FROM [dbo].[credit_card_transactions$]
	GROUP BY city, exp_type
)
SELECT
city , MAX(case when rn_asc=1 then exp_type end) as lowest_exp_type
, MIN(case when rn_desc=1 then exp_type end) as highest_exp_type
from
(
SELECT * , 
	RANK() OVER(PARTITION BY city ORDER BY total_amount DESC) AS rn_desc,
	RANK() OVER(PARTITION BY city ORDER BY total_amount ASC) AS rn_asc
FROM cte ) A
GROUP BY city;

--6) write a query to find percentage contribution of spends by females for each expense type

SELECT exp_type,
SUM(CASE WHEN GENDER = 'F' THEN AMOUNT ELSE 0 END)*1.0 / SUM(amount) AS percentage_female_contribution
FROM [dbo].[credit_card_transactions$]
GROUP BY exp_type
ORDER BY percentage_female_contribution DESC;
/*
exp_type	    percentage_female_contribution
Bills	        0.686194268177345
Food	        0.575583943967959
Grocery	        0.517066507241873
Entertainment	0.503597639814973
Fuel	        0.501170644025753
*/

--7) which card and expense type combination saw highest month over month growth in Jan-2014

WITH cte AS (
SELECT card_type, exp_type, DATEPART(year, transaction_date) AS yt, DATEPART(month, transaction_date) AS mt,
SUM(amount) AS total_spend
FROM [dbo].[credit_card_transactions$]
GROUP BY card_type, exp_type, DATEPART(year, transaction_date), DATEPART(month, transaction_date)
)
SELECT TOP 1 * , (total_spend - prev_month_spend)*1.0 / prev_month_spend AS mom_growth FROM (
SELECT *,
LAG(total_spend, 1) OVER(PARTITION BY card_type, exp_type ORDER BY yt,mt) AS prev_month_spend
FROM cte) A
WHERE prev_month_spend IS NOT NULL AND yt = '2014' AND mt = '1'
ORDER BY mom_growth DESC;

/*
card_type	exp_type	yt	    mt	total_spend	 prev_month_spend	mom_growth
Platinum	Grocery	    2014	1	6361612	     4274083	        0.488415643776688
*/

--8) during weekends which city has highest total spend to total no of transcations ratio 

SELECT TOP 1 city, SUM(amount)*1.0 / COUNT(1) AS ratio
FROM [dbo].[credit_card_transactions$]
WHERE DATEPART(weekday, transaction_date) IN (1,7)
GROUP BY city
ORDER BY ratio DESC;

/*
city	      ratio
Tekkalakote	  298938
*/

--9) which city took least number of days to reach its 500th transaction after the first transaction in that city

WITH cte AS (
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY CITY ORDER BY transaction_date,transaction_id) AS rn
FROM [dbo].[credit_card_transactions$]
)
SELECT top 1 city, DATEDIFF(day, MIN(transaction_date), MAX(transaction_date)) AS dateinterval
FROM cte
WHERE rn = 1 OR rn = 500
GROUP BY city
HAVING COUNT(1) = 2
ORDER BY dateinterval;

/*
city	    dateinterval
Bengaluru	82
*/