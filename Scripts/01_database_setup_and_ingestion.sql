CREATE DATABASE ecommerce;
USE ecommerce;

SET GLOBAL local_infile = 1;
-- =================================================================================
-- MASTER E-COMMERCE DATA WAREHOUSE STRUCTURING SUITE
-- OBJECTIVE: Define schemas and high-speed data streams for all 9 Olist tables.
-- =================================================================================

-- 1. CUSTOMERS TABLE
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2),
    PRIMARY KEY (customer_id)
);
SELECT @@secure_file_priv;
-- =================================================================================
-- PRODUCTION FIX: SECURE FILE PRIVILEGE MATCHED INGESTION
-- OBJECTIVE: Pulls directly from the officially mandated secure server folder.
-- =================================================================================
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ecommerce\\olist_customers_dataset.csv' 
INTO TABLE customers  
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from customers;

-- 2. GEOLOCATION TABLE
DROP TABLE IF EXISTS geolocation;
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10, 8),
    geolocation_lng DECIMAL(11, 8),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ecommerce\\olist_geolocation_dataset.csv'
INTO TABLE geolocation 
FIELDS TERMINATED BY ','
 ENCLOSED BY '"' 
 LINES TERMINATED BY '\n' 
 IGNORE 1 ROWS;
 
select count(*) from geolocation;


-- 3. ORDERS TABLE
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATE,       -- Changed from DATETIME to DATE
    order_approved_at DATE,              -- Changed from DATETIME to DATE
    order_delivered_carrier_date DATE,    -- Changed from DATETIME to DATE
    order_delivered_customer_date DATE,   -- Changed from DATETIME to DATE
    order_estimated_delivery_date DATE,   -- Changed from DATETIME to DATE
    PRIMARY KEY (order_id)
);


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ecommerce\\olist_orders_dataset.csv'
INTO TABLE orders 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(order_id, customer_id, order_status, @p, @a, @car, @cus, @e)
SET 
    -- If text is 'null' or empty, make it a true SQL NULL, else load the YYYY-MM-DD string directly
    order_purchase_timestamp = CASE WHEN TRIM(@p) = '' OR TRIM(@p) = 'null' THEN NULL ELSE TRIM(@p) END,
    order_approved_at = CASE WHEN TRIM(@a) = '' OR TRIM(@a) = 'null' THEN NULL ELSE TRIM(@a) END,
    order_delivered_carrier_date = CASE WHEN TRIM(@car) = '' OR TRIM(@car) = 'null' THEN NULL ELSE TRIM(@car) END,
    order_delivered_customer_date = CASE WHEN TRIM(@cus) = '' OR TRIM(@cus) = 'null' THEN NULL ELSE TRIM(@cus) END,
    order_estimated_delivery_date = CASE WHEN TRIM(@e) = '' OR TRIM(@e) = 'null' THEN NULL ELSE TRIM(@e) END;

select count(*) from orders;

-- 4. ORDER ITEMS TABLE
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ecommerce\\olist_order_items_dataset.csv'
INTO TABLE order_items FIELDS TERMINATED BY ','
 ENCLOSED BY '"' 
 LINES TERMINATED BY '\n' 
 IGNORE 1 ROWS;

select count(*) from order_items;


-- 5. ORDER PAYMENTS TABLE
DROP TABLE IF EXISTS order_payments;
CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10, 2)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ecommerce\\olist_order_payments_dataset.csv'
INTO TABLE order_payments 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

select count(*) from order_payments;

-- 6. ORDER REVIEWS TABLE
DROP TABLE IF EXISTS order_reviews;
CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ecommerce\\olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\n' 
 IGNORE 1 ROWS;

select count(*) from order_reviews;

-- 7. PRODUCTS TABLE
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,
    PRIMARY KEY (product_id)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ecommerce\\olist_products_dataset.csv'
INTO TABLE products 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

select count(*) from products;

-- 8. SELLERS TABLE
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2),
    PRIMARY KEY (seller_id)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ecommerce\\olist_sellers_dataset.csv'
INTO TABLE sellers
 FIELDS TERMINATED BY ',' 
 ENCLOSED BY '"' 
 LINES TERMINATED BY '\n' 
 IGNORE 1 ROWS;

select count(*) from sellers;

-- 9. PRODUCT CATEGORY TRANSLATION TABLE
DROP TABLE IF EXISTS product_category_translation;
CREATE TABLE product_category_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ecommerce\\product_category_name_translation.csv'
INTO TABLE product_category_translation 
FIELDS TERMINATED BY ','
 ENCLOSED BY '"' 
 LINES TERMINATED BY '\n'
 IGNORE 1 ROWS;
 
 select count(*) from product_category_translation ;