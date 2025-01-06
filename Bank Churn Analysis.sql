Create Database CRM;
use crm;

select * from activecustomer

Describe activecustomer;

SELECT ï»¿ActiveID FROM activecustomer WHERE ï»¿ActiveID IS NULL OR ï»¿ActiveID = '';

SET SQL_SAFE_UPDATES = 1;

UPDATE activecustomer 
SET ï»¿ActiveID = 0 
WHERE ï»¿ActiveID IS NULL OR ï»¿ActiveID = '';


ALTER TABLE activecustomer change column ï»¿ActiveID active_id INT,
change column ActiveCategory active_category TEXT;

select * from bank_churn;

Describe bank_churn;

ALTER TABLE bank_churn change column ï»¿CustomerId customer_id INT,
change column CreditScore Credit_Score  INT,
change column Tenure tenure INT,
change column Balance balance DOUBLE,
change column NumOfProducts num_of_products INT,
change column HasCrCard has_cr_card INT,
change column IsActiveMember is_active_member INT,
change column Exited exited INT;

select * from creditcard;

Describe creditcard;

SELECT ï»¿CreditID FROM creditcard WHERE ï»¿CreditID IS NULL OR ï»¿CreditID = '';

ALTER TABLE creditcard change column ï»¿CreditID credit_id INT,
change column Category category TEXT;

select * from customerinfo;

describe customerinfo;

SET SQL_SAFE_UPDATES=1

select month(Bank_DOJ) from customerinfo;

UPDATE customerinfo
SET BankDOJ = STR_TO_DATE(Bank_DOJ, '%d-%m-%Y')
where Bank_DOJ is not null;

ALTER TABLE customerinfo DROP COLUMN Bank_DOJ;

ALTER TABLE customerinfo RENAME COLUMN BankDOJ TO Bank_DOJ;

Alter table customerinfo change column ï»¿CustomerId customer_id varchar(100);

select * from exitcustomer;

Describe exitcustomer;

Alter table exitcustomer change column ï»¿ExitID exit_id INT,
change column ExitCategory Exit_Category TEXT;

select * from gender;

Describe gender;

Alter table gender change column ï»¿GenderID gender_id INT,
change column GenderCategory gender_category TEXT;

select * from geography;

Describe geography;

Alter table geography change column ï»¿GeographyID geography_id INT,
change column GeographyLocation geography_location TEXT;



-- Subjective Question
-- 1.	What is the distribution of account balances across different regions?

SELECT g.geography_location,COUNT(ci.customer_id) AS NumberOfCustomers,ROUND(SUM(bc.balance),2) AS TotalBalance,
ROUND(AVG(bc.balance),2) AS AverageBalance
FROM bank_churn bc
JOIN customerinfo ci on bc.customer_id = ci.customer_id
Join geography g on ci.GeographyID = g.geography_id
GROUP BY g.geography_location;



-- 2.	Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. 

SELECT customer_id, Surname, EstimatedSalary
FROM customerinfo
WHERE MONTH(Bank_DOJ) IN (10, 11, 12)
ORDER BY EstimatedSalary DESC
LIMIT 5;

select Bank_DOJ from customerinfo;

ALTER TABLE customerinfo ADD COLUMN BankDOJ DATE;



describe customerinfo;

SET SQL_SAFE_UPDATES=1

select month(Bank_DOJ) from customerinfo;

UPDATE customerinfo
SET BankDOJ = STR_TO_DATE(Bank_DOJ, '%d-%m-%Y')
where Bank_DOJ is not null;

ALTER TABLE customerinfo DROP COLUMN Bank_DOJ;

ALTER TABLE customerinfo RENAME COLUMN BankDOJ TO Bank_DOJ;


-- 3.	Calculate the average number of products used by customers who have a credit card.

select round(avg(num_of_products),2) as avg_products 
from bank_churn
where has_cr_card = 1;

-- 4.	Determine the churn rate by gender for the most recent year in the dataset.

select * from bank_churn;
select * from customerinfo;
select * from gender;

select g.gender_category, round(sum(bc.exited)/count(bc.customer_id),2) as churn_rate
from bank_churn bc
join customerinfo ci on bc.customer_id = ci.customer_id
join gender g on ci.GenderID = g.gender_id
where YEAR(ci.Bank_DOJ) = (SELECT MAX(YEAR(Bank_DOJ)) FROM customerinfo)
GROUP BY g.gender_category; 


-- 5.	Compare the average credit score of customers who have exited and those who remain

select * from exitcustomer;
select * from bank_churn;

select 
case when exited = 1 then "Exited"
else "Retained"
end as customer_status,
ROUND(AVG(Credit_Score),2) AS Average_Credit_Score
from bank_churn
group by exited;


-- 6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts

select * from customerinfo;
select * from bank_churn;
select * from gender;
select * from activecustomer;

select g.gender_category,round(avg(EstimatedSalary),2) as avg_estimated_salary
from gender g
join customerinfo ci on g.gender_id = ci.GenderID
join bank_churn bc on ci.customer_id = bc.customer_id
where is_active_member =1
group by g.gender_category
order by avg_estimated_salary desc;


-- 7.	Segment the customers based on their credit score and identify the segment with the highest exit rate

select * from bank_churn;

SELECT CASE WHEN Credit_Score BETWEEN 350 AND 550 THEN 'Low'
WHEN Credit_Score BETWEEN 551 AND 700 THEN 'Medium'
WHEN Credit_Score BETWEEN 701 AND 850 THEN 'High'
    END AS Credit_Score_Segment,
    ROUND(SUM(exited) / COUNT(*), 4) AS Exit_Rate
FROM bank_churn
GROUP BY Credit_Score_Segment
ORDER BY Exit_Rate DESC;


-- 8.	Find out which geographic region has the highest number of active customers with a tenure greater than 5 years

select * from customerinfo;
select * from bank_churn;
select * from geography;

select g.geography_location,count(bc.is_active_member) as active_customer
from geography g
join customerinfo ci on g.geography_id = ci.GeographyID
join bank_churn bc on ci.customer_id = bc.customer_id
where bc.is_active_member =1
and bc.tenure > 5
group by g.geography_location
order by active_customer desc
limit 1;


-- 9.	What is the impact of having a credit card on customer churn, based on the available data?

select * from bank_churn;

SELECT has_cr_card,ROUND(SUM(exited) / COUNT(*), 4) AS Churn_Rate
FROM bank_churn
GROUP BY has_cr_card;


-- 10.	For customers who have exited, what is the most common number of products they have used?


select num_of_products, count(*) as total_customers
from bank_churn
where exited = 1
group by num_of_products
order by total_customers desc
limit 1;


-- 11.	Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.

select * from customerinfo;


SELECT month(Bank_DOJ) AS Joining_Month,
COUNT(*) AS Number_of_Customers
FROM customerinfo
GROUP BY Joining_Month
ORDER BY Joining_Month;

SELECT year(Bank_DOJ) AS Joining_year,
COUNT(*) AS Number_of_Customers
FROM customerinfo
GROUP BY Joining_year
ORDER BY Joining_year;


-- 12.	Analyze the relationship between the number of products and the account balance for customers who have exited?

select NumOfProducts,COUNT(Customer_ID) as ExitedCustomers,
ROUND(AVG(Balance),2) as AverageBalance from bank_churn
where Exited=1
group by NumOfProducts;


-- 13.	Identify any potential outliers in terms of balance among customers who have remained with the bank.

SELECT customer_id,balance
FROM bank_churn
WHERE exited = 0;


-- 15. write a query to find out the gender-wise average income of males and females in each geography id. 
-- Also, rank the gender according to the average value. 


select * from customerinfo;
select * from gender;


SELECT 
    CASE 
        WHEN ci.GenderID = 1 THEN 'Male'
        WHEN ci.GenderID = 2 THEN 'Female'
        ELSE 'Other' END AS gender_category,
    ci.GeographyID,Round(AVG(ci.EstimatedSalary),2) AS avg_income,
    RANK() OVER (PARTITION BY ci.GeographyID ORDER BY Round(AVG(ci.EstimatedSalary),2) DESC) AS ranked_income
FROM customerinfo ci
GROUP BY ci.GenderID, ci.GeographyID
ORDER BY ci.GeographyID, ranked_income;


-- 16. write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

select * from bank_churn;

SELECT 
    CASE 
        WHEN ci.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN ci.Age BETWEEN 31 AND 50 THEN '31-50'
        WHEN ci.Age > 50 THEN '50+'
    END AS age_bracket,
    ROUND(AVG(bc.Tenure),2) AS avg_tenure
FROM bank_churn bc
JOIN customerinfo ci on bc.customer_id = ci.customer_id
WHERE bc.Exited = 1  
GROUP BY age_bracket
ORDER BY age_bracket;



-- 17.	Is there any direct correlation between salary and the balance of the customers? And is it different for people who have exited or not?

select * from customerinfo;
select * from Bank_churn;
select * from exitcustomer;

select ci.customer_id,ci.surname as cust_name, ci.EstimatedSalary,
bc.balance,ec.Exit_category
from customerinfo ci
join Bank_churn bc on ci.customer_id = bc.customer_id
join exitcustomer ec on bc.exited = ec.exit_id
where bc.exited = 1
order by bc.balance desc;


select ci.customer_id,ci.surname as cust_name, ci.EstimatedSalary,
bc.balance,ec.Exit_category
from customerinfo ci
join Bank_churn bc on ci.customer_id = bc.customer_id
join exitcustomer ec on bc.exited = ec.exit_id
where bc.exited = 0
order by bc.balance desc;


-- 18.	Is there any correlation between the salary and the Credit score of customers?

select * from Bank_churn;
select * from customerinfo;

SELECT ci.customer_id,ci.Surname AS cust_name,
ci.EstimatedSalary as customer_salary,bc.Credit_Score,bc.has_cr_card as credit_id
FROM customerinfo ci
JOIN Bank_churn bc ON ci.customer_id = bc.customer_id;


-- 19.	Rank each bucket of credit score as per the number of customers who have churned the bank?

SELECT CASE WHEN Credit_Score BETWEEN 350 AND 550 THEN 'Low'
WHEN Credit_Score BETWEEN 551 AND 700 THEN 'Medium'
WHEN Credit_Score BETWEEN 701 AND 850 THEN 'High'
    END AS Credit_Score_Bucket,
count(customer_id) as churned_customer,
rank() over (order by count(customer_id) desc) as bucket_rank
FROM bank_churn
where exited = 1
GROUP BY Credit_Score_Bucket
ORDER BY bucket_rank;


-- 20.	According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets that have lesser 
-- than average number of credit cards per bucket.

-- According to the age buckets find the number of customers who have a credit card

SELECT 
   CASE WHEN ci.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN ci.Age BETWEEN 31 AND 50 THEN '31-50'
        WHEN ci.Age > 50 THEN '50+'
    END AS age_bracket,
    count(ci.customer_id) as total_customers
FROM bank_churn bc
JOIN customerinfo ci on bc.customer_id = ci.customer_id
WHERE bc.has_cr_card = 1  
GROUP BY age_bracket
ORDER BY age_bracket;

-- Retrieve those buckets that have lesser than average number of credit cards per bucket.

with age_creditcard_customers as (SELECT 
   CASE WHEN ci.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN ci.Age BETWEEN 31 AND 50 THEN '31-50'
        WHEN ci.Age > 50 THEN '50+'
    END AS age_bracket,
    count(ci.customer_id) as creditcard_customers
FROM bank_churn bc
JOIN customerinfo ci on bc.customer_id = ci.customer_id
WHERE bc.has_cr_card = 1  
GROUP BY age_bracket),
avg_creditcard as (select avg(creditcard_customers) as avg_creditcard_customers_perbucket
from age_creditcard_customers)

select acc.age_bracket, acc.creditcard_customers
from age_creditcard_customers acc
cross join avg_creditcard ac
where acc.creditcard_customers < ac.avg_creditcard_customers_perbucket
order by acc.creditcard_customers asc;


-- 21.Rank the Locations as per the number of people who have churned the bank and average balance of the customers.

select * from customerinfo;

WITH LocationChurnData AS (
    SELECT 
        g.geography_id, g.geography_location,
        COUNT(ci.customer_id) AS Churned_customers,
        ROUND(AVG(bc.Balance),2) AS AvgBalance
    from geography g
    join customerinfo ci on g.geography_id = ci.GeographyID
    join Bank_churn bc on ci.customer_id = bc.customer_id
    where bc.Exited = 1
    GROUP BY g.geography_id, g.geography_location)
    
SELECT geography_id,geography_location,
    Churned_customers,AvgBalance,
    RANK() OVER (ORDER BY Churned_customers DESC) AS ChurnRank,
    RANK() OVER (ORDER BY AvgBalance DESC) AS BalanceRank
FROM LocationChurnData
ORDER BY ChurnRank, BalanceRank;



-- 22.	As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table 
-- where the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.


select customer_id,Surname,
concat(customer_id,'_',Surname) as CustomerID_Surname
from customerinfo;


-- 23.	Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.

select * from exitcustomer;

SELECT 
    bc.*,
    (SELECT ec.Exit_Category 
     FROM exitcustomer ec 
     WHERE ec.exit_id = bc.exited) AS ExitCategory
FROM 
    Bank_Churn bc
    order by bc.balance desc;


-- 25.Write the query to get the customer IDs, their last name, and whether they are active or not for the 
-- customers whose surname ends with “on”.

Select 
	c.CustomerID,
    c.Surname as LastName,
    a.ActiveCategory
From 
	customerinfo c
    inner join bank_churn b on c.CustomerID = b.CustomerID
    inner join activecustomer a on a.ActiveID = b.ActiveID
Where
	c.Surname like '%on';
    
    
--     26.	Can you observe any data disrupency in the Customer’s data? As a hint it’s present in the IsActiveMember and Exited columns.
--     One more point to consider is that the data in the Exited Column is absolutely correct and accurate.


SET SQL_SAFE_UPDATES = 1

UPDATE Bank_churn 
SET is_active_member = 0 
WHERE exited = 1 and is_active_member = 1;

Select * from Bank_churn
where exited = 1;


-- Subjective Question:

-- 1.	Customer Behavior Analysis: What patterns can be observed in the spending habits of long-term customers compared to new customers, and
--  what might these patterns suggest about customer loyalty?

SELECT 
    CASE 
        WHEN b.Tenure > 3 THEN 'Long-Term'
        ELSE 'New'
    END AS CustomerType,
    Round(AVG(b.Balance),2) AS AvgBalance,
    COUNT(b.CustomerID) AS NumberOfCustomers,
    Round(AVG(b.NumOfProducts),2) AS AvgProducts,
    Round(AVG(b.CreditScore),2) AS AvgCreditScore
FROM 
    bank_churn b
GROUP BY 
    CustomerType
ORDER BY 
    CustomerType DESC;
    
    
--    2.	Product Affinity Study: Which bank products or services are most commonly used together, and how might this influence cross-selling 
--    strategies? 

Select 
num_of_products,
Count(customer_id) As Number_of_customers,
Round(Count(customer_id)/(select count(*) from bank_churn )*100,2) As percentage_of_customers
from bank_churn
GROUP BY num_of_products
ORDER BY Number_of_customers desc;



-- 3.	Geographic Market Trends: How do economic indicators in different geographic regions correlate with the number of active accounts and 
-- customer churn rates?

SELECT 
g.geography_id,g.geography_location,
COUNT(ci.customer_id) AS TotalAccounts,
COUNT(CASE WHEN bc.is_active_member = 1 THEN 1 END) AS ActiveAccounts,
ROUND((COUNT(CASE WHEN bc.is_active_member = 1 THEN 1 END) * 100.0 / 
COUNT(ci.customer_id)), 2) AS active_percentage,
COUNT(CASE WHEN bc.exited = 1 THEN 1 END) AS ChurnedAccounts,
ROUND((COUNT(CASE WHEN bc.exited = 1 THEN 1 END) * 100.0 / 
COUNT(ci.customer_id)), 2) AS churn_percentage
FROM 
bank_churn bc
JOIN customerinfo ci ON bc.customer_id = ci.customer_id
JOIN geography g ON ci.GeographyID = g.geography_id
GROUP BY g.geography_id, g.geography_location;


-- 4.	Risk Management Assessment: Based on customer profiles, which demographic segments appear to pose the highest financial risk to the bank,
--  and why?

SELECT 
    ci.age,
    ci.GenderID,
    g.geography_location,
    AVG(bc.balance) AS AvgBalance,
    AVG(bc.credit_score) AS AvgCreditScore,
    COUNT(CASE WHEN bc.exited = 1 THEN 1 END) AS TotalChurned,
    COUNT(ci.customer_id) AS TotalCustomers,
    ROUND((COUNT(CASE WHEN bc.exited = 1 THEN 1 END) * 100.0) / COUNT(ci.customer_id), 2) AS ChurnRate
FROM bank_churn bc
    JOIN customerinfo ci ON bc.customer_id = ci.customer_id
    JOIN geography g ON ci.GeographyID = g.geography_id
GROUP BY ci.age, ci.GenderID, g.geography_location
ORDER BY ChurnRate DESC, AvgCreditScore ASC;


-- 5.	Customer Tenure Value Forecast: How would you use the available data to model and predict the lifetime (tenure) value in the bank of 
-- different customer segments?


WITH CustomerSegments AS (
    SELECT ci.customer_id,ci.Age,ci.EstimatedSalary,ci.GenderID,
        bc.Credit_Score,bc.tenure,bc.balance,g.geography_location,
        bc.num_of_products,cc.category AS credit_category,a.active_category,e.Exit_Category,
        AVG(bc.balance) OVER (PARTITION BY g.geography_location, ci.GenderID) AS AvgBalance,
        AVG(bc.tenure) OVER (PARTITION BY g.geography_location, ci.GenderID) AS AvgTenure
    FROM bank_churn bc
        JOIN customerinfo ci ON ci.customer_id = bc.customer_id
        JOIN geography g ON ci.GeographyID = g.geography_id
        LEFT JOIN creditcard cc ON bc.has_cr_card = cc.credit_id
        LEFT JOIN activecustomer a ON a.active_id = bc.is_active_member
        LEFT JOIN exitcustomer e ON bc.exited = e.exit_id
)
SELECT 
    geography_location,
    GenderID,
    ROUND(AVG(AvgBalance), 2) AS EstimatedAvgBalance,
    ROUND(AVG(AvgTenure), 2) AS EstimatedAvgTenure,
    COUNT(*) AS CustomerCount,
    ROUND(AVG(AvgBalance) * AVG(AvgTenure), 2) AS EstimatedLifetimeValue
FROM CustomerSegments
GROUP BY geography_location, GenderID;


-- 7.	Customer Exit Reasons Exploration: Can you identify common characteristics or trends among customers who have exited that could 
-- explain their reasons for leaving?

SELECT 
    g.geography_location,
    ge.gender_category,
    ROUND(AVG(bc.Credit_Score), 2) AS AvgCreditScore,
    ROUND(AVG(bc.tenure), 2) AS AvgTenure,
    ROUND(AVG(bc.balance), 2) AS AvgBalance,
    ROUND(AVG(bc.num_of_products), 2) AS AvgNumOfProducts,
    ROUND(AVG(ci.Age), 2) AS AVGAge,
    COUNT(bc.customer_id) AS TotalExitedCustomer
FROM bank_churn bc
    JOIN customerinfo ci ON ci.customer_id = bc.customer_id
    JOIN geography g ON ci.GeographyID = g.geography_id
    JOIN gender ge ON ci.GenderID = ge.gender_id
WHERE exited = 1
GROUP BY ge.gender_category, g.geography_location
ORDER BY TotalExitedCustomer DESC;
    


-- 9.	Utilize SQL queries to segment customers based on demographics and account details.

SELECT g.geography_location,ge.gender_category,
    CASE 
        WHEN bc.balance < 50000 THEN 'Low Balance'
        WHEN bc.balance BETWEEN 50000 AND 100000 THEN 'Medium Balance'
        ELSE 'High Balance'
    END AS BalanceSegment,
    COUNT(ci.customer_id) AS TotalCustomers,
    AVG(bc.tenure) AS AvgTenure,
    AVG(ci.Age) AS AvgAge,
    AVG(bc.Credit_Score) AS AvgCreditScore,
    cc.category AS credit_card_category
FROM bank_churn bc
    JOIN creditcard cc ON bc.has_cr_card = cc.credit_id
    JOIN customerinfo ci ON ci.customer_id = bc.customer_id
    JOIN geography g ON ci.GeographyID = g.geography_id
    JOIN gender ge ON ci.GenderID = ge.gender_id
GROUP BY g.geography_location, ge.gender_category, BalanceSegment, cc.category
ORDER BY g.geography_location, ge.gender_category, BalanceSegment;


-- 14.	In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?

ALTER TABLE bank_churn
CHANGE HasCrCard Has_creditcard INT;

SELECT * from bank_churn;




