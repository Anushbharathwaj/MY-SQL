use DATAMART;

select * from weekly_sales limit 10;

drop table clean_weekly_sales;

## A- Data Cleansing

create table clean_weekly_sales as
select 
week_date, 
week(week_date) as week_number , 
month(week_date) as month_number,
monthname(week_date) as month_name,
year(week_date) as calendar_year, 
	case 
		when segment='null' then 'Unknown'
        else segment
	end as 'segment',
	case
		when Right(segment,1)= '1' then 'Young Adults'  
		when Right(segment,1)= '2' then 'Middle Aged'
		when Right(segment,1) in ('3','4') then 'Retirees'
		else 'Unknown'
	end as 'age_band',
	case 
		when Left(segment,1)='C' then 'Couples'
        when Left(segment,1)='F' then 'Families'
        else 'Unknown'
	end as 'demographic',
platform,
region,
Round(sales/transactions,2) as 'avg_transaction',
transactions,
sales
from weekly_sales;

select * from clean_weekly_sales limit 10;

##  B - Data Exploration

-- 1. Which week numbers are missing from the dataset?

-- Understanding
drop table cont;
create table cont(x int auto_increment primary key);
insert into cont values (),(),();
select * from cont;

-- seq 100
drop table seq100;

create table seq100(x int auto_increment primary key);

insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();

insert into seq100 select x+50 from seq100;

select * from seq100;

-- seq 52
drop table seq52;

create table seq52 as select x from seq100 limit 52;

select * from seq52;

-- distinct week

select distinct week_number from clean_weekly_sales;

-- solution

select x as 'Miss_week_numbers' from seq52 where x not in (select distinct week_number from clean_weekly_sales);

## 2. How many total transactions were there for each year in the dataset?

select calendar_year as 'Year' ,sum(avg_transaction) as 'Total Transactions' from clean_weekly_sales group by Year;

## 3. What are the total sales for each region for each month?

select month_name , month_number ,region ,sum(sales) from clean_weekly_sales group by month_name, month_number,region;

## 4. What is the total count of transactions for each platform?

select platform , count(transactions) from clean_weekly_sales group by platform;

select platform , sum(transactions) from clean_weekly_sales group by platform;

## 5. What is the percentage of sales for Retail vs Shopify for each month?

-- understanding 

select platform , month_name ,calendar_year, sum(sales) as Sales from clean_weekly_sales group by  platform , month_name,calendar_year;
-- U2
with cte_sales as
(select platform , month_name ,calendar_year, sum(sales) as Sales from clean_weekly_sales group by  platform , month_name,calendar_year)
select platform , month_name, calendar_year, Sales from cte_sales;

-- U3

with cte_sales as
(select platform , month_name ,calendar_year, sum(sales) as Sales from clean_weekly_sales group by  platform , month_name,calendar_year)
select platform , month_name ,calendar_year,
case
when platform = 'Retail' then Sales 
else 0
end as 'Retail_sales',
case
when platform = 'Shopify' then Sales 
else 0
end as 'Shopify_sales'
from cte_sales;

-- U4
with cte_sales as
(select platform , month_name ,calendar_year, sum(sales) as Sales from clean_weekly_sales group by  platform , month_name,calendar_year)
select
platform , month_name ,calendar_year,
  ROUND(
    100 * MAX(CASE WHEN platform = 'Retail' THEN Sales ELSE 0 END) /
      SUM(Sales),
    2
  ) AS retail_percentage,
   ROUND(
    100 * MAX(CASE WHEN platform = 'Shopify' THEN Sales ELSE 0 END) /
      SUM(Sales),
    2
  ) AS shopify_percentage
from cte_sales group by platform , month_name ,calendar_year
order by  platform , month_name ,calendar_year;

--
WITH cte_monthly_platform_sales AS (
  SELECT
    month_number,calendar_year,
    platform,
    SUM(sales) AS monthly_sales
  FROM clean_weekly_sales
  GROUP BY month_number,calendar_year, platform
  
)
SELECT
  month_number,calendar_year,
  ROUND(100*
     max(CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) /
      SUM(monthly_sales),
    2
  ) AS retail_percentage,
  ROUND(100*
    max(CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END) /
      SUM(monthly_sales),
    2
  ) AS shopify_percentage
FROM cte_monthly_platform_sales
GROUP BY month_number,calendar_year
ORDER BY month_number,calendar_year;

--

select demographic, SUM(sales)/SUM(SUM(SALES)) OVER (PARTITION BY demographic) from clean_weekly_sales group by demographic ;

-- ans
with cte_montly_sales as
( select month_number , calendar_year , platform , SUM(sales) as saless from clean_weekly_sales group by month_number , calendar_year , platform )
select month_number , calendar_year ,
	ROUND( 100 * MAX(case when platform = 'Retail' then saless else NULL end) / SUM(saless),2) as 'retail_perc',
	ROUND( 100 * MAX(case when platform = 'Shopify' then saless else NULL end) / SUM(saless),2) as 'shopify_perc'
from cte_montly_sales
group by month_number , calendar_year 
order by month_number , calendar_year ;
			
## 6.What is the percentage of sales by demographic for each year in the dataset?

select calendar_year, demographic , sum(sales) as year_sales, round( 100 * sum(sales)/sum(sum(sales)) over(partition by demographic),2)as perc from clean_weekly_sales 
group by calendar_year, demographic
order by calendar_year, demographic;





## 7. Which age_band and demographic values contribute the most to Retail sales?

select age_band , demographic , sum(sales) as Sales from clean_weekly_sales where platform = 'Retail' group by age_band , demographic order by  Sales desc;

