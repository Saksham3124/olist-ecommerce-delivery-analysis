-- ============================================================
-- OLIST E-COMMERCE DELIVERY PERFORMANCE ANALYSIS
-- Author: Kumar Saksham
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
-- Description: End-to-end SQL analysis identifying delivery
--              performance issues, seller risk, and business impact
-- ============================================================


-- ------------------------------------------------------------
-- SECTION 1: DATABASE SETUP
-- ------------------------------------------------------------

CREATE TABLE customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    customer_zip_code_prefix VARCHAR,
    customer_city VARCHAR,
    customer_state VARCHAR
);

CREATE TABLE sellers (
    seller_id VARCHAR PRIMARY KEY,
    seller_zip_code_prefix VARCHAR,
    seller_city VARCHAR,
    seller_state VARCHAR
);

CREATE TABLE products (
    product_id VARCHAR PRIMARY KEY,
    product_category_name VARCHAR,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

CREATE TABLE orders (
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR REFERENCES customers(customer_id),
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
    order_id VARCHAR REFERENCES orders(order_id),
    order_item_id INTEGER,
    product_id VARCHAR REFERENCES products(product_id),
    seller_id VARCHAR REFERENCES sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC
);

CREATE TABLE order_payments (
    order_id VARCHAR REFERENCES orders(order_id),
    payment_sequential INTEGER,
    payment_type VARCHAR,
    payment_installments INTEGER,
    payment_value NUMERIC
);

CREATE TABLE order_reviews (
    review_id VARCHAR,
    order_id VARCHAR REFERENCES orders(order_id),
    review_score INTEGER,
    review_comment_title VARCHAR,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR,
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city VARCHAR,
    geolocation_state VARCHAR
);


-- ------------------------------------------------------------
-- SECTION 2: DATA QUALITY CHECKS
-- ------------------------------------------------------------

-- 2.1 Row counts across all tables
SELECT 'customers' as table_name, COUNT(*) as row_count FROM customers UNION ALL
SELECT 'sellers',                  COUNT(*) FROM sellers UNION ALL
SELECT 'products',                 COUNT(*) FROM products UNION ALL
SELECT 'orders',                   COUNT(*) FROM orders UNION ALL
SELECT 'order_items',              COUNT(*) FROM order_items UNION ALL
SELECT 'order_payments',           COUNT(*) FROM order_payments UNION ALL
SELECT 'order_reviews',            COUNT(*) FROM order_reviews UNION ALL
SELECT 'geolocation',              COUNT(*) FROM geolocation;

-- 2.2 Null check on critical columns in orders table
-- Finding: 2,965 orders have no delivery date (cancelled/in-transit)
-- Action: Excluded from all delivery analysis using IS NOT NULL filter
SELECT
    COUNT(*)                              AS total_rows,
    COUNT(order_id)                       AS order_id_filled,
    COUNT(customer_id)                    AS customer_id_filled,
    COUNT(order_delivered_customer_date)  AS delivered_date_filled,
    COUNT(order_estimated_delivery_date)  AS estimated_date_filled
FROM orders;

-- 2.3 Order status breakdown
SELECT
    order_status,
    COUNT(*) as total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 2.4 Dataset date range
SELECT
    MIN(order_purchase_timestamp) as earliest_order,
    MAX(order_purchase_timestamp) as latest_order
FROM orders;

-- 2.5 Duplicate check on orders
SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------
-- SECTION 3: DELIVERY PERFORMANCE ANALYSIS
-- ------------------------------------------------------------

-- 3.1 Overall late order rate
-- Result: 7,826 late orders out of 96,470 delivered = 8.11%
SELECT
    COUNT(*) AS total_delivered,
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_percentage
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL;

-- 3.2 Average and maximum delay in days (late orders only)
SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date
        - order_estimated_delivery_date))/86400), 2) AS avg_delay_days,
    ROUND(MAX(EXTRACT(EPOCH FROM (order_delivered_customer_date
        - order_estimated_delivery_date))/86400), 2) AS max_delay_days
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date > order_estimated_delivery_date;

-- 3.3 Monthly delay trend (months with 50+ orders only)
-- Finding: Nov 2017 spike to 14.31% — Black Friday demand surge
-- Finding: Feb 2018 spike to 15.99% — secondary logistics stress point
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_percentage
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
HAVING COUNT(*) >= 50
ORDER BY month;


-- ------------------------------------------------------------
-- SECTION 4: GEOGRAPHIC ANALYSIS
-- ------------------------------------------------------------

-- 4.1 Late order rate by customer state
-- Finding: AL=23.93%, MA=19.67%, PI=15.97% — all Northeast Brazil
-- Insight: Geographic distance from sellers concentrated in Southeast
--          is the primary driver of Northeast delay rates
SELECT
    c.customer_state,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_percentage
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY late_percentage DESC;


-- ------------------------------------------------------------
-- SECTION 5: BUSINESS IMPACT ANALYSIS
-- ------------------------------------------------------------

-- 5.1 Impact of late delivery on customer review scores
-- Finding: On Time avg = 4.29, Late avg = 2.57
-- Insight: Late delivery causes a 40% collapse in customer satisfaction score
SELECT
    CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
         THEN 'Late' ELSE 'On Time' END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(*) AS total_orders
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- 5.2 Revenue at risk from late deliveries by seller
-- Top seller: R$26,524 revenue across 128 late orders, avg review 2.23
SELECT
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS late_orders,
    ROUND(SUM(oi.price), 2) AS revenue_at_risk,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY oi.seller_id
ORDER BY revenue_at_risk DESC
LIMIT 10;


-- ------------------------------------------------------------
-- SECTION 6: SELLER RISK ANALYSIS
-- ------------------------------------------------------------

-- 6.1 Top 10 worst sellers by late delivery rate
-- Filter: minimum 50 orders to exclude statistically insignificant sellers
-- Finding: Top seller has 35.62% late rate — 1 in 3 orders late
SELECT
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT o.order_id), 2) AS late_percentage
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT o.order_id) > 50
ORDER BY late_percentage DESC
LIMIT 10;

-- 6.2 Seller risk scoring — combines delay rate, volume and review score
-- High risk = high late % + high revenue + low review score
SELECT
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT o.order_id), 2) AS late_percentage,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    CASE
        WHEN SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
             THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT o.order_id) > 25
             THEN 'High Risk'
        WHEN SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
             THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT o.order_id) > 15
             THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_tier
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT o.order_id) > 50
ORDER BY late_percentage DESC;


-- ------------------------------------------------------------
-- SECTION 7: MASTER VIEW FOR DASHBOARD
-- ------------------------------------------------------------

-- 7.1 Combined view used for Tableau dashboard
CREATE VIEW olist_master_dashboard AS
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
         THEN 'Late' ELSE 'On Time' END AS delivery_status,
    EXTRACT(EPOCH FROM (o.order_delivered_customer_date -
        o.order_estimated_delivery_date))/86400 AS delay_days,
    c.customer_state,
    oi.seller_id,
    oi.price,
    r.review_score,
    DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL;