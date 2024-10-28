CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 
INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');


CREATE TABLE users(userid integer,signup_date date); 
INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

CREATE TABLE sales(userid integer,created_date date,product_id integer); 
INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

CREATE TABLE product(product_id integer,product_name text,price integer); 
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- Questions 

-- Q1. Total amount customer spent on Zomato ?

select a.userid,SUM(b.price) as total_amt_spent
from sales a
Inner join product b
ON a.product_id = b.product_id
group by a.userid
order by total_amt_spent DESC

-- Q2. How many days each customer visited Zomato ?

select userid,count(DISTINCT created_date) as distinct_days from sales
group by userid;

-- Q3. What was the first product purchased by each customer ?

select * from
(select *,rank() over(partition by userid order by created_date asc)as rnk from sales ) where rnk = 1

-- Q4. What is the most purchased item on the menu and how many times was it purchased by all customers ?

select product_id,count(product_id) cnt
from sales 
group by product_id
order by count(product_id) desc
limit 1

-- Q5. Which item was most popular for each of the customer 
With demo as (
Select userid,product_id,count(product_id),
rank() over(partition by userid order by count(product_id) DESC) as rnk 
from sales 
group by userid,product_id)

select * from demo where rnk = 1

--Q6. Which item was first purchased by the customer after they became a member ?

With ranked_sales as 
(
SELECT 
    a.userid,
    a.created_date,
    a.product_id,
    b.gold_signup_date,
    RANK() OVER(PARTITION BY a.userid ORDER BY a.created_date ASC) AS rank_order
FROM 
    sales a 
INNER JOIN 
    goldusers_signup b 
ON 
    a.userid = b.userid
AND 
    a.created_date > b.gold_signup_date
)
select * from ranked_sales
where rank_order = 1;

-- Q7. Which item was purchased just before the customer became the member ?

With ranked_sales AS 
(
SELECT 
    a.userid,
    a.created_date,
    a.product_id,
    b.gold_signup_date,
    RANK() OVER(PARTITION BY a.userid ORDER BY a.created_date DESC) AS rank_order
FROM 
    sales a 
INNER JOIN 
    goldusers_signup b 
ON 
    a.userid = b.userid
AND 
    a.created_date < b.gold_signup_date
)
select * from ranked_sales 
where rank_order = 1;

-- Q8. - What is the total orders and amount spent for each member before they became a member ?


SELECT 
    a.userid,
    COUNT(a.created_date) AS order_purchased,
    SUM(c.price) AS total_price
FROM 
    sales a 
INNER JOIN 
    goldusers_signup b 
ON 
    a.userid = b.userid
INNER JOIN 
    product c 
ON 
    a.product_id = c.product_id
AND 
    a.created_date <= b.gold_signup_date
GROUP BY 
    a.userid;

-- Q9. Rank all the transactions of the customers 

Select *,rank() over(partition by userid order by created_date) rnk from sales 

-- Q10. Rank all transactions for each member whenever they have a zomato gold member for every non gold member transaction as Null. 


SELECT 
    a.userid,
    a.created_date,
    a.product_id,
    b.gold_signup_date,
	RANK () OVER (partition by a.userid order by created_date desc) as rnk 
FROM 
    sales a 
Left JOIN 
    goldusers_signup b 
ON 
    a.userid = b.userid
AND 
    a.created_date > b.gold_signup_date

