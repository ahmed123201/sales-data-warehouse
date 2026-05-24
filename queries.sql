-- ─────────────────────────────────────────
-- Sales Data Warehouse - Analytical Queries
-- ─────────────────────────────────────────

-- 1. Net profit by department (descending)
SELECT d.department_name, 
       ROUND(SUM(f.net_profit), 2) AS net_profit
FROM warehouse.fact_sales f
INNER JOIN warehouse.dim_department d ON f.department_id = d.department_id
GROUP BY d.department_name
ORDER BY 2 DESC;

-- ─────────────────────────────────────────

-- 2. Net profit by product category (descending)
SELECT p.product_category, 
       ROUND(SUM(f.net_profit), 2) AS net_profit
FROM warehouse.fact_sales f
INNER JOIN warehouse.dim_product p ON f.product_id = p.product_id
GROUP BY p.product_category
ORDER BY 2 DESC;

-- ─────────────────────────────────────────

-- 3. Monthly sales performance
SELECT d.month, 
       ROUND(SUM(f.net_profit), 2) AS net_profit
FROM warehouse.fact_sales f
INNER JOIN warehouse.dim_date d ON f.date_id = d.date_id
GROUP BY d.month
ORDER BY d.month;

-- ─────────────────────────────────────────

-- 4. Top 3 most profitable categories
SELECT p.product_category, 
       ROUND(SUM(f.net_profit), 2) AS net_profit
FROM warehouse.fact_sales f
INNER JOIN warehouse.dim_product p ON f.product_id = p.product_id
GROUP BY p.product_category
ORDER BY 2 DESC
LIMIT 3;

-- ─────────────────────────────────────────

-- 5. Most used payment method by profit
SELECT payment, 
       ROUND(SUM(net_profit), 2) AS net_profit
FROM warehouse.fact_sales
GROUP BY payment
ORDER BY 2 DESC;

-- ─────────────────────────────────────────

-- 6. Average transaction value by department
SELECT d.department_name, 
       ROUND(AVG(f.sale_price), 2) AS avg_sale
FROM warehouse.fact_sales f
INNER JOIN warehouse.dim_department d ON f.department_id = d.department_id
GROUP BY d.department_name
ORDER BY 2 DESC;

-- ─────────────────────────────────────────

-- 7. Best selling day of the week
SELECT 
    CASE 
        WHEN d.weekday = 0 THEN 'Monday'
        WHEN d.weekday = 1 THEN 'Tuesday'
        WHEN d.weekday = 2 THEN 'Wednesday'
        WHEN d.weekday = 3 THEN 'Thursday'
        WHEN d.weekday = 4 THEN 'Friday'
        WHEN d.weekday = 5 THEN 'Saturday'
        WHEN d.weekday = 6 THEN 'Sunday'
    END AS day_name,
    ROUND(SUM(f.net_profit), 2) AS net_profit
FROM warehouse.fact_sales f
INNER JOIN warehouse.dim_date d ON f.date_id = d.date_id
GROUP BY d.weekday
ORDER BY 2 DESC;

-- ─────────────────────────────────────────
-- INDEXES FOR QUERY OPTIMIZATION
-- ─────────────────────────────────────────

-- Index on foreign keys to speed up JOINs
CREATE INDEX idx_fact_sales_product    ON warehouse.fact_sales(product_id);
CREATE INDEX idx_fact_sales_department ON warehouse.fact_sales(department_id);
CREATE INDEX idx_fact_sales_date       ON warehouse.fact_sales(date_id);
CREATE INDEX idx_fact_sales_customer   ON warehouse.fact_sales(customer_id);
