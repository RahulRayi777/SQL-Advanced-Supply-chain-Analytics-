#Top 5 Customers by Sales (2021)
SELECT 
    c.customer_name, 
    SUM(s.sold_quantity) AS total_sold_qty, 
    ROUND(SUM(s.sold_quantity * g.gross_price), 2) AS total_sales
FROM fact_sales_monthly s
JOIN dim_customer c ON s.customer_code = c.customer_code
JOIN fact_gross_price g ON s.product_code = g.product_code 
    AND s.fiscal_year = g.fiscal_year
WHERE get_fiscal_year(s.date) = 2021
GROUP BY c.customer_name
ORDER BY total_sales DESC
LIMIT 5;

#Top 5 Products by Sales Quantity (2021)
SELECT 
    p.product, 
    SUM(s.sold_quantity) AS total_sold_qty
FROM fact_sales_monthly s
JOIN dim_product p ON s.product_code = p.product_code
WHERE get_fiscal_year(s.date) = 2021
GROUP BY p.product
ORDER BY total_sold_qty DESC
LIMIT 5;

#Monthly Sales Trend (2021
SELECT 
    MONTH(s.date) AS month, 
    SUM(s.sold_quantity) AS total_sold_qty
FROM fact_sales_monthly s
WHERE get_fiscal_year(s.date) = 2021
GROUP BY month
ORDER BY month;

# Customer Sales in Different Markets (2021)
SELECT 
    c.customer_name, 
    c.market, 
    SUM(s.sold_quantity) AS total_sold_qty
FROM fact_sales_monthly s
JOIN dim_customer c ON s.customer_code = c.customer_code
WHERE get_fiscal_year(s.date) = 2021
GROUP BY c.customer_name, c.market
ORDER BY total_sold_qty DESC;

#Gross Sales by Product Category (2021)
SELECT 
    p.category, 
    ROUND(SUM(s.sold_quantity * g.gross_price), 2) AS total_gross_sales
FROM fact_sales_monthly s
JOIN dim_product p ON s.product_code = p.product_code
JOIN fact_gross_price g ON s.product_code = g.product_code 
    AND s.fiscal_year = g.fiscal_year
WHERE get_fiscal_year(s.date) = 2021
GROUP BY p.category
ORDER BY total_gross_sales DESC;



#Customer Sales in India (2021):
SELECT
  *
FROM 
 fact_sales_monthly s 
JOIN 
 dim_customer c
ON s.customer_code = c.customer_code
WHERE get_fiscal_year(s.date) = 2021 
  AND c.market = 'India'
GROUP BY c.market;

#Product Sales Analysis

EXPLAIN ANALYZE
SELECT 
    s.date, 
    s.product_code, 
    p.product, 
    p.variant, 
    s.sold_quantity, 
    g.gross_price,
    ROUND(s.sold_quantity * g.gross_price, 2) AS gross_price_total,
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_product p
    ON s.product_code = p.product_code
JOIN dim_date dd
    ON dd.calender_date = s.date
JOIN fact_gross_price g
    ON g.fiscal_year = dd.fiscal_year
    AND g.product_code = s.product_code
JOIN fact_pre_invoice_deductions pre
    ON pre.customer_code = s.customer_code 
    AND pre.fiscal_year = dd.fiscal_year
WHERE get_fiscal_year(s.date) = 2021     
LIMIT 1000000;


##Sales and Market Contribution Analysis
select customer, round(sum(net_sales)/1000000,2) as net_sales_mln, 
       net_sales_mln*100/sum(net_sales_mln) over() as pct_net_sales
from net_sales_m s
join dim_customer c on s.customer_code = c.customer_code
where s.fiscal_year = 2021 and c.market = 'India'
group by customer
order by net_sales_mln desc;


##Sales and Market Contribution Analysis:
select customer, round(sum(net_sales)/1000000,2) as net_sales_mln, 
       net_sales_mln*100/sum(net_sales_mln) over() as pct_net_sales
from net_sales_m s
join dim_customer c on s.customer_code = c.customer_code
where s.fiscal_year = 2021 and c.market = 'India'
group by customer
order by net_sales_mln desc;

#Forecast Accuracy Comparison (2020 vs 2021):
select 
    f_2020.customer_code, f_2020.customer_name, f_2020.market, 
    f_2020.forecast_accuracy as forecast_acc_2020, 
    f_2021.forecast_accuracy as forecast_acc_2021
from forecast_accuracy_2020 f_2020
join forecast_accuracy_2021 f_2021
on f_2020.customer_code = f_2021.customer_code 
where f_2021.forecast_accuracy < f_2020.forecast_accuracy
order by forecast_acc_2020 desc;

#6. Customer Sales Growth (2020 vs 2021):
WITH sales_2020 AS (
    SELECT 
        customer_code, 
        SUM(sold_quantity) AS total_sold_qty_2020
    FROM fact_sales_monthly
    WHERE get_fiscal_year(date) = 2020
    GROUP BY customer_code
),
sales_2021 AS (
    SELECT 
        customer_code, 
        SUM(sold_quantity) AS total_sold_qty_2021
    FROM fact_sales_monthly
    WHERE get_fiscal_year(date) = 2021
    GROUP BY customer_code
)
SELECT 
    c.customer_name, 
    s20.total_sold_qty_2020, 
    s21.total_sold_qty_2021,
    ROUND(((s21.total_sold_qty_2021 - s20.total_sold_qty_2020) / s20.total_sold_qty_2020) * 100, 2) AS sales_growth_pct
FROM sales_2020 s20
JOIN sales_2021 s21 ON s20.customer_code = s21.customer_code
JOIN dim_customer c ON s20.customer_code = c.customer_code
ORDER BY sales_growth_pct DESC;

# Top 5 Markets by Sales (2021)
SELECT 
    c.market, 
    SUM(s.sold_quantity) AS total_sold_qty, 
    ROUND(SUM(s.sold_quantity * g.gross_price), 2) AS total_sales
FROM fact_sales_monthly s
JOIN dim_customer c ON s.customer_code = c.customer_code
JOIN fact_gross_price g ON s.product_code = g.product_code 
    AND s.fiscal_year = g.fiscal_year
WHERE get_fiscal_year(s.date) = 2021
GROUP BY c.market
ORDER BY total_sales DESC
LIMIT 5;

#Product Sales by Variant (2021)
SELECT 
    p.product, 
    p.variant, 
    SUM(s.sold_quantity) AS total_sold_qty
FROM fact_sales_monthly s
JOIN dim_product p ON s.product_code = p.product_code
WHERE get_fiscal_year(s.date) = 2021
GROUP BY p.product, p.variant
ORDER BY total_sold_qty DESC;


#Year-over-Year Sales Comparison by Market
WITH sales_2020 AS (
    SELECT 
        c.market, 
        SUM(s.sold_quantity) AS total_sold_qty_2020
    FROM fact_sales_monthly s
    JOIN dim_customer c ON s.customer_code = c.customer_code
    WHERE get_fiscal_year(s.date) = 2020
    GROUP BY c.market
),
sales_2021 AS (
    SELECT 
        c.market, 
        SUM(s.sold_quantity) AS total_sold_qty_2021
    FROM fact_sales_monthly s
    JOIN dim_customer c ON s.customer_code = c.customer_code
    WHERE get_fiscal_year(s.date) = 2021
    GROUP BY c.market
)
SELECT 
    s20.market, 
    s20.total_sold_qty_2020, 
    s21.total_sold_qty_2021, 
    ROUND(((s21.total_sold_qty_2021 - s20.total_sold_qty_2020) / s20.total_sold_qty_2020) * 100, 2) AS sales_growth_pct
FROM sales_2020 s20
JOIN sales_2021 s21 ON s20.market = s21.market
ORDER BY sales_growth_pct DESC;


'''
-->Insights:
1. Top Customers & Products: Helps prioritize resources on top customers and high-demand products.
2. Seasonal Trends: Monthly sales data reveal trends for inventory management and promotional planning.
3. Market Performance: Insights into which markets or regions are performing best across customers.
4. Category Analysis: Helps guide product development or marketing efforts based on category performance.'''


##Helper Table Creation
drop table if exists fact_act_est;

create table fact_act_est as
(
    select 
        s.date, s.fiscal_year, s.product_code, s.customer_code, s.sold_quantity, f.forecast_quantity
    from fact_sales_monthly s
    left join fact_forecast_monthly f using (date, customer_code, product_code)
)
union
(
    select 
        f.date, f.fiscal_year, f.product_code, f.customer_code, s.sold_quantity, f.forecast_quantity
    from fact_forecast_monthly f
    left join fact_sales_monthly s using (date, customer_code, product_code)
);

update fact_act_est
set sold_quantity = 0
where sold_quantity is null;

update fact_act_est
set forecast_quantity = 0
where forecast_quantity is null;

##Product Sales & Gross Price Analysis:
SELECT 
    s.date, p.product, p.variant, s.sold_quantity, g.gross_price,
    ROUND(s.sold_quantity * g.gross_price, 2) as gross_price_total,
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_product p ON s.product_code = p.product_code
JOIN dim_date dd ON dd.calender_date = s.date
JOIN fact_gross_price g ON g.fiscal_year = dd.fiscal_year AND g.product_code = s.product_code
JOIN fact_pre_invoice_deductions pre ON pre.customer_code = s.customer_code 
WHERE get_fiscal_year(s.date) = 2021 
LIMIT 1000000;

##Forecast Accuracy Report (CTE and Temporary Table)
with forecast_err_table as (
    select
        s.customer_code, c.customer as customer_name, c.market,
        sum(s.sold_quantity) as total_sold_qty, sum(s.forecast_quantity) as total_forecast_qty,
        sum(s.forecast_quantity-s.sold_quantity) as net_error,
        round(sum(s.forecast_quantity-s.sold_quantity)*100/sum(s.forecast_quantity),1) as net_error_pct,
        sum(abs(s.forecast_quantity-s.sold_quantity)) as abs_error,
        round(sum(abs(s.forecast_quantity-sold_quantity))*100/sum(s.forecast_quantity),2) as abs_error_pct
    from fact_act_est s
    join dim_customer c on s.customer_code = c.customer_code
    where s.fiscal_year=2021
    group by customer_code
)
select 
    *, if (abs_error_pct > 100, 0, 100.0 - abs_error_pct) as forecast_accuracy
from forecast_err_table
order by forecast_accuracy desc;

##CTE for Net Sales and Percentage Calculation
with cte1 as (
	select 
            c.customer, 
            round(sum(s.net_sales)/1000000,2) as net_sales_mln
    from net_sales_m s
    join dim_customer c
        on s.customer_code=c.customer_code
    where s.fiscal_year=2021
    group by c.customer
)
select 
        *,
        net_sales_mln * 100 / sum(net_sales_mln) over () as pct_net_sales
from cte1
order by net_sales_mln desc;

#Triggers for Automating Insertions
CREATE TRIGGER fact_sales_monthly_AFTER_INSERT AFTER INSERT ON fact_sales_monthly 
FOR EACH ROW 
BEGIN
    insert into fact_act_est (date, product_code, customer_code, sold_quantity)
    values (NEW.date, NEW.product_code, NEW.customer_code, NEW.sold_quantity)
    on duplicate key update sold_quantity = values(sold_quantity);
END;

CREATE TRIGGER fact_forecast_monthly_AFTER_INSERT AFTER INSERT ON fact_forecast_monthly 
FOR EACH ROW 
BEGIN
    insert into fact_act_est (date, product_code, customer_code, forecast_quantity)
    values (NEW.date, NEW.product_code, NEW.customer_code, NEW.forecast_quantity)
    on duplicate key update forecast_quantity = values(forecast_quantity);
END;








