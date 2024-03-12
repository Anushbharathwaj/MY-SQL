use DATABANK;

select * from customer_nodes;

select * from customer_transactions;

select * from regions;

## 1. How many different nodes make up the Data Bank network?

select count(distinct(node_id)) as 'Unique_Nodes' from customer_nodes;

## 2. How many nodes are there in each region?

select r.region_name, count(cn.node_id) as count_no from customer_nodes cn inner join regions r on cn.region_id = r.region_id group by r.region_name order by r.region_name  ;

## 3. How many customers are divided among the regions?

select r.region_name , count(cn.customer_id ) as count_no from customer_nodes cn inner join regions r on cn.region_id = r.region_id group by r.region_name order by count_no desc;

## 4. Determine the total amount of transactions for each region name?

select r.region_name , sum(txn_amount) as amount from regions r inner join customer_nodes cn on r.region_id = cn.region_id inner join customer_transactions ct on ct.customer_id = cn.customer_id group by r.region_name order by r.region_name ;

## 5.How long does it take on an average to move clients to a new node?

select round(avg(datediff(end_date,start_date)),2) from customer_nodes where end_date != '9999-12-31';
-- understanding
select end_date from customer_nodes where end_date = '9999-12-31';
-- understanding
select end_date,count(*) from customer_nodes group by end_date;

## 6. What is the unique count and total amount for each transaction type?

select txn_type ,  count(txn_type) as No ,sum(txn_amount) as Total_Transaction from customer_transactions group by txn_type;

## 7. What is the average number and size of past deposits across all customers?

-- understanding
select txn_type , count(*) from customer_transactions group by txn_type;
-- under
select count(distinct(customer_id)) as d from customer_transactions  ;
-- solution HERE

select round(count(customer_id) / count(distinct(customer_id)),2)as AVG_COUNT, concat('$',round(avg(txn_amount),2)) as AVG_DEPOSIT from customer_transactions where txn_type = 'deposit';

## 8. For each month - how many Data Bank customers make more than 1 deposit and at least either 1 purchase or 1 withdrawal in a single month?

with trans_cte as ( select monthname(txn_date) as Months, customer_id , sum(if(txn_type = 'deposit',1,0))  as 'Deposit', sum(if(txn_type = 'withdrawal',1,0))  as 'Withdrawal', sum(if(txn_type = 'purchase',1,0))  as 'Purchase' from customer_transactions group by Months,customer_id)
select  Months, count(customer_id) as NO from trans_cte where Deposit > 1 and (Withdrawal =1 or Purchase =1) group by Months order by Months;

-- understanding

select monthname(txn_date) as Months, customer_id , sum(if(txn_type = 'deposit',1,0))  as 'Deposit', sum(if(txn_type = 'withdrawal',1,0))  as 'Withdrawal', sum(if(txn_type = 'purchase',1,0))  as 'Purchase' from customer_transactions group by Months,customer_id ;



