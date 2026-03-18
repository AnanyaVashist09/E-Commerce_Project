Create database capstone;

use capstone;

# tables : 
select * from orders_csv;
select * from customers_csv;
select * from product_csv1;
select * from returns_csv;

# table_columns :
# orders_csv : order_id , product_id , customer_id, order_date , ordertime , status , quantity,unit_price , Amount
# customers_csv : customer_id , first_name,last_name,full_name , email , phone , country , city , address
# products_csv1 : product_id , product name , sub-category , category , price , stock_status
# returns_csv : order_id , customer_id , return_reason , return_status

ALTER TABLE product_csv1
CHANGE `product name` product_name VARCHAR(255);

alter table product_csv1
change `sub-category` sub_category varchar(255);



### Sales Performance Anlaysis :

### (KPI) :

# total_orders:
select count(order_id) as total_orders from orders_csv;

# total Sales amount :
select round(sum(amount),2) as TotalSales from orders_csv;

# total products : 
select count(product_id) as Total_products from product_csv1;

# total registered and delivered products:
Select  count(case when status = 'registered' then 1 end) as total_registered_products,
count(case when status = 'delivered' then 1 end) as  total_delivered_products
from orders_csv;

# total Customers : 
select count(customer_id) as Total_customers from customers_csv;

# average order quantity :
select round(avg(quantity),2) as AvgQuantity from orders_csv;

# Total sales of each year
select  year(str_to_date(order_date, '%d-%m-%Y')) as year, 
round(sum(Amount),2) as TotalSales
from Orders_csv
group by year(str_to_date(order_date, '%d-%m-%Y'))
order by year;

# total orders of each year :
select year(str_to_date(order_date, '%d-%m-%Y')) as year , count(order_id) as Total_orders 
from orders_csv
group by year(str_to_date(order_date, '%d-%m-%Y')) 
order by year;

# customers in each year :
select year(str_to_date(order_date, '%d-%m-%Y')) as year , count(distinct customer_id) as Total_customers 
from orders_csv
group by year(str_to_date(order_date, '%d-%m-%Y')) 
order by year;




# current year sales, previous year sales and Percentage change in sales 
set @SelectedYear = 2022; 
select @SelectedYear as SelectedYear,
round(sum(case when year(str_to_date(order_date, '%d-%m-%Y')) = @SelectedYear then Amount else 0 end), 2) 
as SalesOfSelectedYear,
round(sum(case when year(str_to_date(order_date, '%d-%m-%Y')) = @SelectedYear - 1 then Amount else 0 end), 2) 
as SalesOfPreviousYear,
round(case when sum(case when year(str_to_date(order_date, '%d-%m-%Y')) = @SelectedYear - 1 then Amount else 0 end) = 0 
then 0 else ((sum(case when year(str_to_date(order_date, '%d-%m-%Y')) = @SelectedYear then Amount else 0 
end) - sum(case when year(str_to_date(order_date, '%d-%m-%Y')) = @SelectedYear - 1 then Amount else 0 
end)) / sum(case WHEN YEAR(STR_TO_DATE(order_date, '%d-%m-%Y')) = @SelectedYear - 1 then Amount else 0 
end)) * 100 end, 2) as PercentageChange
from Orders_csv
where year(str_to_date(order_date, '%d-%m-%Y')) in (@SelectedYear, @SelectedYear - 1);


### YOY% , MOM% :
-- yoy% calculation
select year(str_to_date(order_date, '%d-%m-%Y')) as year,round(sum(amount),2) as total_sales,
round((sum(amount) - lag(sum(amount), 1) over (order by year(str_to_date(order_date, '%d-%m-%Y')))) / 
lag(sum(amount), 1) over (order by year(str_to_date(order_date, '%d-%m-%Y'))) * 100, 2) as yoy_percentage
from orders_csv
group by year(str_to_date(order_date, '%d-%m-%Y'));

-- mom% calculation
select year(str_to_date(order_date, '%d-%m-%Y')) as year,month(str_to_date(order_date, '%d-%m-%Y')) as month,
round(sum(amount),2) as total_sales,
round((sum(amount) - lag(sum(amount), 1) over (order by year(str_to_date(order_date, '%d-%m-%Y')), month(str_to_date(order_date, '%d-%m-%Y')))) / 
lag(sum(amount), 1) over (order by year(str_to_date(order_date, '%d-%m-%Y')), month(str_to_date(order_date, '%d-%m-%Y'))) * 100, 2) as mom_percentage
from orders_csv
group by year(str_to_date(order_date, '%d-%m-%Y')), month(str_to_date(order_date, '%d-%m-%Y'));




    
## Product_Analysis : 
# total products :
select count(product_id) as Total_products from product_csv1;

# total categories :
select count( distinct category) as Total_Categories from product_csv1;

# total sub_categories : 
select count( distinct sub_category) as Total_Subcategories from product_csv1;


# Category wise avg price :
select category , round(avg(price),1) as AvgPrice 
from product_csv1 
group by category
order by AvgPrice desc;


# top 10 most bought products:
select p.product_id,p.product_name,count(o.order_id) as total_orders
from product_csv1 p
join orders_csv o on p.product_id = o.product_id
group by p.product_id, p.product_name
order by total_orders desc
limit 10;

# category contribution to total revenue : 
select  p.Category, round(SUM(o.amount),2) AS TotalSales, 
concat(round((sum(o.amount) / (select sum(amount) from Orders_csv)) * 100, 2), '%') as PercentageContribution
from Product_csv1 as p
join  Orders_csv o on p.Product_ID = o.Product_ID
group by p.Category
order by TotalSales desc;


# sub-category contribution to total revenue
select  p.sub_category, round(SUM(o.amount),2) AS TotalSales, 
concat(round((sum(o.amount) / (select sum(amount) from Orders_csv)) * 100, 2), '%') as PercentageContribution
from Product_csv1 as p
join  Orders_csv o on p.Product_ID = o.Product_ID
group by p.sub_category
order by TotalSales desc;


# top 10 categories with most number of orders :
select p.category, count(o.order_id) as total_orders
from orders_csv o
join product_csv1 p on o.product_id = p.product_id
group by p.category
order by total_orders desc
limit 10;


# Top 10 sub-categories with most number of orders :
select p.sub_category, count(o.order_id) as total_orders
from orders_csv o
join product_csv1 p on o.product_id = p.product_id
group by p.sub_category
order by total_orders desc
limit 10;


# Year wise Top 10 categories with most orders : 
select p.category,count(o.order_id) as total_orders
from orders_csv o
join product_csv1 p on o.product_id = p.product_id
where year(str_to_date(o.order_date, '%d-%m-%Y')) = 2023  
group by p.category
order by total_orders desc
limit 10;

# country wise product popularity : 
select C.country, P.Product_name, sum(O.quantity) as total_quantity_sold
from Orders_csv O
join Product_csv1 P on O.product_id = P.product_id
join Customers_csv C on O.customer_id = C.customer_id
group by C.country, P.Product_name
order by total_quantity_sold desc;

# number of products out of stock : 
select count(*) as out_of_stock_count
from product_csv1
where stock_status = 'Out of Stock';

# names of products that are ordered in 2024 and are out-of-stock :
select p.Product_name
from product_csv1 p
join orders_csv o on p.product_id = o.product_id
where p.stock_status = 'Out of Stock'
and year(str_to_date(o.order_date, '%Y-%m-%d')) = 2024
and o.status='Registered';



## customers analysis :
 
# total customers :
select count(customer_id) as Total_customers from customers_csv;

# Total countries : 
select count(distinct country) as Total_countries from customers_csv;

# total cities :
select count(distinct city) as Total_Cities from customers_csv;

# top 10 countries with most sales using selected_year
set @selectedYear=2023;
select c.Country,round(sum(o.Amount),2) as total_sales
from Orders_csv as o
join customers_csv c
on o.Customer_id = c.Customer_id
where year(str_to_date(o.order_date, '%Y-%m-%d')) = @selectedYear  
group by c.Country
order by total_sales desc
limit 10;


# top 10 cities with most sales using selected_year
set @selectedYear=2020;
select c.city,round(sum(o.Amount),2) as total_sales
from Orders_csv as o
join customers_csv c
on o.Customer_id = c.Customer_id
where year(str_to_date(o.order_date, '%Y-%m-%d')) = @selectedYear  
group by c.city
order by total_sales desc
limit 10;


# top 10 countries with most number of orders using Year
set @selectedYear=2023;
select c.Country,count(o.order_id) as total_orders
from Orders_csv as o
join customers_csv c
on o.Customer_id = c.Customer_id
where year(str_to_date(o.order_date, '%Y-%m-%d')) = @selectedYear  
group by c.Country
order by total_orders desc
limit 10;

# top 10 cities with most number of orders :
set @selectedYear=2023;
select c.city,count(o.order_id) as total_orders
from Orders_csv as o
join customers_csv c
on o.Customer_id = c.Customer_id
where year(str_to_date(o.order_date, '%Y-%m-%d')) = @selectedYear  
group by c.city
order by total_orders desc
limit 10;

# total revenue generated by each country :
select C.country, round(sum(O.Amount),2) AS total_sales
from Orders_csv O
join Customers_csv C on O.customer_id = C.customer_id
group by C.country
order by total_sales desc;



# total revenue generated by each city :
select C.city, round(sum(O.Amount),2) as total_sales
from Orders_csv O
join Customers_csv C on O.customer_id = C.customer_id
group by C.city
order by total_sales desc;

# Country wise total customers : 
select country, count(customer_id) as customer_count
from Customers_csv
group by country
order by customer_count desc;


# customers with repeated orders:
select c.customer_id, c.full_name,count(o.order_id) as order_count
from customers_csv as c
join orders_csv o on c.customer_id = o.customer_id
group by c.customer_id, c.full_name
having order_count > 1
order by count(o.order_id) desc;


# total count of customers with repeated orders :
select count(distinct customer_id) as repeated_customer_count
from orders_csv
where customer_id in 
(select customer_id from orders_csv
group by customer_id
having count(order_id) > 1);



# names of customers who are making a purchase for the second time and have purchased the same product 
with CustomerOrderRank as (select c.customer_id, c.full_name, c.country, c.city, o.product_id, o.order_date,
Row_number() over (partition by o.customer_id, o.product_id order by STR_TO_DATE(o.order_date, '%Y-%m-%d')) as purchase_rank
from customers_csv c
join orders_csv o on c.customer_id = o.customer_id
join product_csv1 p on o.product_id = p.product_id
)
select distinct c.full_name, c.country, c.city, p.product_name
from CustomerOrderRank r
join customers_csv c on r.customer_id = c.customer_id
join product_csv1 p on r.product_id = p.product_id
where r.purchase_rank = 2;



## Returns analysis :


# Total Returns :
select count(Order_id) as Total_returns from Returns_csv;

# return Reasons : 
Select Distinct return_reason from returns_csv;

# count of total return reasons :
Select count(Distinct return_reason) as Total_reasons from returns_csv;


# customers with most returns :
SELECT c.customer_id,c.full_name, COUNT(r.order_id) AS return_count
FROM customers_csv c
JOIN returns_csv r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY return_count DESC
limit 10;



# Top 10 countries with most number of returns :
SELECT c.country, COUNT(r.order_id) AS return_count
FROM customers_csv c
JOIN returns_csv r ON c.customer_id = r.customer_id
GROUP BY c.country
ORDER BY return_count DESC
limit 10;



SELECT c.city as Cities , COUNT(r.order_id) AS return_count
FROM customers_csv as  c
JOIN returns_csv as r ON c.customer_id = r.customer_id
GROUP BY c.city
ORDER BY return_count DESC
limit 10;


# top 10 most returned products : 
select p.product_name, count(r.order_id) as return_count
from returns_csv r
join orders_csv o on r.order_id = o.order_id
join product_csv1 p on o.product_id = p.product_id
group by p.product_name
order by return_count desc
limit 10;

# return reason wise return count
select return_reason, count(order_id) as return_count
from returns_csv
group by return_reason
order by return_count desc;

























