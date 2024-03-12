use Texture_Tales;

select * from product_details;
select * from product_hierarchy;
select * from product_prices;
select * from sales;

 #1 What was the total quantity sold for all products?
 select details.product_name as product , sum(qty) as qty from product_details as details inner join sales 
 on details.product_id = sales.prod_id 
 group by product 
 order by qty desc;
 
 #2 What is the total generated revenue for all products before discounts?

-- Understand
 select  p.product_name,s.qty * s.price as Total  from sales s inner join product_details p  on p.product_id = s.prod_id ;
 
-- now,
 select concat('$',sum(qty * price)) as Total from sales ;
 
 #3 What was the total discount amount for all products?
 
-- understanding 
  select  p.product_name,sum(s.qty * s.price * s.discount)/100 as Total  from sales s inner join product_details p  on p.product_id = s.prod_id group by p.product_name ;

--
 select concat(sum(price*qty*discount)/100,'%') as Total from sales;
 
 #4 How many unique transactions were there?
 
 --
 select count(txn_id) from sales;
 
 -- unique
 
 select count(distinct txn_id) from sales;
 
 #5 What are the average unique products purchased in each transaction?
 
 with cte_trans as 
 (
 select t.txn_id , count(distinct p.product_name) as counts 
 from sales t inner join product_details p 
 on p.product_id = t.prod_id 
 group by t.txn_id
 )
 select round(avg(counts)) as avg_prod from cte_trans;
 
 #6 What is the average discount value per transaction?
 
 with cte_discount as 
 (
 select txn_id, sum(discount * qty * price)/100 as discount from sales group by txn_id
 )
 select round(avg(discount)) as avg_discount from cte_discount;
 
 #7 What is the average revenue for member transactions and non- member transactions?
 with cte_revenue as 
 (
 select member ,txn_id, sum(qty*price) as revenue from sales group by member,txn_id
 )
 select member, round(avg(revenue)) as avg_revenue from cte_revenue group by member;
 
 #8 What are the top 3 products by total revenue before discount?
 
 select p.product_name,sum(s.qty*s.price) as revenue  from
 product_details p inner join sales s 
 on p.product_id = s.prod_id 
 group by p.product_name 
 order by revenue desc
 limit 3;
 
 #9  What are the total quantity, revenue and discount for each segment?
 select p.segment_id,p.segment_name, sum(s.qty*s.price) as revenue , sum(s.qty*s.price*s.discount)/100 as discount
 from sales s inner join product_details p
 on p.product_id = s.prod_id
 group by  p.segment_name, p.segment_id;
 
 #10 What is the top selling product for each segment?
 select p.product_id,p.style_id,p.segment_name,p.product_name , sum(s.qty) as qty 
 from product_details p inner join sales s 
 on p.product_id=s.prod_id
 group by p.segment_name,p.product_name, p.product_id,p.style_id ; 
 
 #11 What are the total quantity, revenue and discount for each category?
 select p.category_name,sum(s.qty) as qty , sum(s.qty*s.price) as revenue , sum(s.qty*s.price*s.discount)/100 as discount 
 from product_details p inner join sales s 
 on p.product_id =  s.prod_id
 group by p.category_name;
 
 #12 What is the top selling product for each category?
 select p.category_name,p.product_name,sum(s.qty) as qty
 from sales s inner join product_details p 
 on p.product_id=s.prod_id 
 group by  p.category_name,p.product_name
 order by qty desc
 limit 5;
 