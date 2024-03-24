use data_mart;
-- Data Cleaning part

drop table if exists clean_weekly_sales;
create table clean_weekly_sales as
select 
week_date,
week(str_to_date(week_date, '%d/%m/%y')) as week_number,
month(str_to_date(week_date, '%d/%m/%y')) as month_number,
year(str_to_date(week_date, '%d/%m/%y')) as calender_year,
region,
platform,
segment,
case
	when right(segment,1)='1' then 'Young Adults'
    when right(segment,1)= '2' then 'Middle Aged'
    when right(segment,1) in ('3','4') then 'Retires'
    else 'Unknown' end as aged_band,
case
	when left(segment,1)='C' then 'Couples'
    when left(segment,1)='F' then 'Families'
    else 'Unknown' end as demographic,
case when segment=null then 'Unknown'
else segment end,
    customer_type,
    transactions,
    sales,
    round(sales/transactions,2) as avg_transaction
from
	weekly_sales;
    
select * from clean_weekly_sales; ## cheking new created table

-- Data Exploration strat from here


-- Q1. What range of week numbers are missing from the dataset?

## creating table for 1 to 100 sequential number 

drop table if exists seq_100;
create table seq_100(x int not null auto_increment primary key);
insert into seq_100 values (),(),(),(),(),(),(),(),(),();
insert into seq_100 values (),(),(),(),(),(),(),(),(),();
insert into seq_100 values (),(),(),(),(),(),(),(),(),();
insert into seq_100 values (),(),(),(),(),(),(),(),(),();
insert into seq_100 values (),(),(),(),(),(),(),(),(),();
insert into seq_100 select x + 50 from seq_100;
select * from seq_100; #Cheking table values

## Creating table for 52 week in a calender year

drop table if exists seq_52;
create table seq_52 as (select x from seq_100 limit 52);
select * from seq_52;

select distinct week_number from clean_weekly_sales; ## Checking existing week

## missing week number
select 
	distinct x as missing_week 
    from seq_52 
    where x not in(select distinct week_number from clean_weekly_sales); 


-- Q2. How many total transactions were there for each year in the dataset?

select 
	calender_year,
    sum(transactions) as total_transactions
from 
	clean_weekly_sales
    group by 
    1;

-- Q3. What is the total sales for each region for each month?
select
	region,
    month_number,
    sum(sales) as total_sales
from 
	clean_weekly_sales
group by
	1,2
order by
	1;

-- Q4. What is the total count of transactions for each platform

select
	platform,
    count(transactions) as total_transaction_count
from
	clean_weekly_sales
group by
	1;

-- Q5. What is the percentage of sales for Retail vs Shopify for each month and year?

with cte_monthly_platform_sales as (
select
	month_number,
    calender_year,
    platform,
    sum(sales) as monthly_sales
from
	clean_weekly_sales
group by
month_number,calender_year,platform)   ## here 1=month_number,2=calender_year,3=platform
  
select 
	month_number,
    calender_year,
    round(max(case when platform='Retail' then monthly_sales 
    else null end)/sum(monthly_sales)*100,2) as retail_percentage,
	round(max(case when platform='Shopify' then monthly_sales 
    else null end)/sum(monthly_sales)*100,2) as shopify_percentage
from 
	cte_monthly_platform_sales
group by
	month_number,
    calender_year
order by
	calender_year asc;

-- Q6. What is the percentage of sales by demographic for each year in the dataset?

select 
	calender_year,
    demographic,
    sum(sales) as yearly_sales,
    round (sum(sales)/sum(sum(sales)) over (partition by demographic) * 100,2) as sales_percentage
from
	clean_weekly_sales
group by
	1,2 ## 1 represent calender_year column, 2 represent demographic column
order by
	1 asc; ## Ascending order by calender_year

-- Q7. Which age_band and demographic values contribute the most to Retail sales?
select 
	aged_band,
    demographic,
    sum(sales) as total_sales
from
	clean_weekly_sales
where
	platform='Retail'
group by 
	1,2 ## 1 represent aged_band column, 2 represent demographic column
order by
	3 desc; ## 3 represent total_sales





-- 