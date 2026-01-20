CREATE DATABASE customers_behavior;
use customers_behavior;
SHOW tables;
drop table customers_analysis;
select * from customers limit 10;
drop database customer_behavior;
-- what is total revenue genrated by male vs female customers?
select gender, sum(purchase_amount) from customers group by gender;
-- which customer use discount but spend more then avg purchase amount?
select customer_id ,purchase_amount from customers where discount_applied= 'yes' and purchase_amount>=(select avg(purchase_amount)from customers);
-- which are the top 5 product with the highest avg review rating ?
select item_purchased,round(avg(review_rating),2) from customers group by item_purchased order by avg(review_rating) desc limit 5;
-- compare the avg purchase amounts between standard and express shoping ?
select shipping_type,round(avg(purchase_amount),2) from customers where shipping_type in ('Standard','Express') group by shipping_type;
-- do subscribe customers spend more ? compare avg spend and total revenue btw subscribe and non-subscribe?
select subscription_status,count(customer_id), avg(purchase_amount) as avg_spend,sum(purchase_amount)  as total_revenue from customers GROUP BY subscription_status ORDER BY total_revenue,avg_spend desc;
-- which 5 product have the highest percentage of purchse with discount applied?
select item_purchased ,round(100*sum(case when discount_applied = 'YES' then 1 else 0 end ) /count(*),2) as discount_rate 
from customers group by item_purchased
order by discount_rate desc limit 5;
-- segment customer into New,Returning and loyal based on their total number of previous purchase, and show the count of each segment 
with customer_type as 
(select customer_id ,previous_purchases, case
when previous_purchases = 1 then 'New' 
when previous_purchases between 2 and 10 then 'Retuening'
else 'Loyal' 
end as customer_segment from customers)
select customer_segment, count(*) as "Number of customer" from customer_type  GROUP BY customer_segment;
-- what are the top 3 purchased product within each category ?
WITH item_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customers
    GROUP BY category, item_purchased
)
SELECT
    item_rank,
    category,
    item_purchased,
    total_orders
FROM item_counts
WHERE item_rank <= 3;
