SELECT * FROM [dbo].[credit_card_transactions$];

--checking the range of data
SELECT MIN(transaction_date), MAX(transaction_date) FROM [dbo].[credit_card_transactions$];
--[2013-10-04 00:00:00.000
--2015-05-26 00:00:00.000]

--checking different card types
SELECT DISTINCT card_type FROM [dbo].[credit_card_transactions$]
/*
card_type
Silver
Signature
Gold
Platinum
*/

--checking different expense types
SELECT DISTINCT exp_type FROM [dbo].[credit_card_transactions$]
/*
exp_type
Entertainment
Food
Bills
Fuel
Grocery
*/

SELECT DISTINCT gender FROM [dbo].[credit_card_transactions$]
/*
GENDER
F
M
*/

SELECT DISTINCT COUNT(*) FROM [dbo].[credit_card_transactions$]
--16383
