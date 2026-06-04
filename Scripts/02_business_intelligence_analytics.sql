USE ecommerce; 

-- =================================================================================
-- PHASE 1: SEMANTIC MODEL CROSS-VALIDATION & RECONCILIATION AUDIT
-- OBJECTIVE: Establish absolute baseline metrics from the raw transaction tables.
-- USE CASE:  These totals serve as the "Source of Truth" answer key to verify that
--            downstream Power BI many-to-many relationship links do not cause 
--            data inflation or duplicate transaction counting.
-- =================================================================================
SELECT 
    COUNT(DISTINCT order_id) AS total_orders_baseline,
    ROUND(SUM(payment_value), 2) AS total_revenue_baseline
FROM order_payments;

-- =================================================================================
-- PHASE 2: REGIONAL LOGISTICS FRICTION & CONTRACT SLA DIAGNOSTICS
-- OBJECTIVE: Calculate actual delivery transit times vs. contract expectations.
-- USE CASE:  Identifies geographic delivery chokepoints. This data structures 
--            the operational storytelling on the Logistics dashboard page.
-- =================================================================================

SELECT 
    c.customer_state AS target_region,
    COUNT(DISTINCT o.order_id) AS total_orders_shipped,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS actual_avg_delivery_days,
    ROUND(AVG(DATEDIFF(o.order_estimated_delivery_date, o.order_purchase_timestamp)), 1) AS expected_sla_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' 
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL
GROUP BY c.customer_state
ORDER BY actual_avg_delivery_days DESC;

-- =================================================================================
-- PHASE 3: COMMERCIAL PERFORMANCE & CATEGORY REVENUE SHARE
-- OBJECTIVE: Identify the top-performing product categories by revenue contribution.
-- USE CASE:  Demonstrates advanced CTE (Common Table Expression) mastery to isolate 
--            the core commercial drivers for portfolio documentation.
-- =================================================================================

WITH CategoryRevenueCTE AS (
    SELECT 
        t.product_category_name_english AS product_category, -- Pulled from translation table
        ROUND(SUM(i.price), 2) AS total_sales_value
    FROM order_items i
    JOIN products p ON i.product_id = p.product_id
    JOIN product_category_translation t ON p.product_category_name = t.product_category_name
    GROUP BY t.product_category_name_english
)
SELECT 
    product_category,
    total_sales_value,
    ROUND((total_sales_value / (SELECT SUM(price) FROM order_items)) * 100, 2) AS revenue_share_percentage
FROM CategoryRevenueCTE
ORDER BY total_sales_value DESC
LIMIT 10;

-- =================================================================================
-- PHASE 4: TIME-SERIES FREQUENCY & MOM REVENUE GROWTH TRENDS
-- OBJECTIVE: Calculate monthly gross revenue and evaluate sequential growth velocity.
-- USE CASE:  Feeds the executive leadership macroeconomic trend dashboard.
-- =================================================================================

WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sales_month,
        ROUND(SUM(i.price), 2) AS current_month_revenue
    FROM orders o
    JOIN order_items i ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),
GrowthCalculations AS (
    SELECT 
        sales_month,
        current_month_revenue,
        LAG(current_month_revenue, 1) OVER (ORDER BY sales_month) AS previous_month_revenue
    FROM MonthlyRevenue
)
SELECT 
    sales_month,
    current_month_revenue,
    COALESCE(previous_month_revenue, 0) AS previous_month_revenue,
    ROUND(
        ((current_month_revenue - previous_month_revenue) / previous_month_revenue) * 100, 
        2
    ) AS mom_growth_percentage
FROM GrowthCalculations
ORDER BY sales_month ASC;

-- =================================================================================
-- PHASE 5: ADVANCED RFM CUSTOMER SEGMENTATION METRICS (RECONCILED COLUMN SCOPE)
-- OBJECTIVE: Rank customers based on Recency, Frequency, and Monetary values.
-- RESOLUTION: Passed total_monetary_investment through the CTE hierarchy to allow
--             proper downstream sorting and visualization.
-- =================================================================================

USE ecommerce;

WITH CustomerBaseMetrics AS (
    SELECT 
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_purchase_date,
        COUNT(DISTINCT o.order_id) AS purchase_frequency,
        SUM(i.price) AS total_monetary_investment -- Created here
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items i ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
), 
RFM_Scores AS (
    SELECT 
        customer_unique_id,
        total_monetary_investment, -- FIXED: Passed through the middle layer here
        -- Higher score to lower DATEDIFF (More recent shoppers get a 5)
        NTILE(5) OVER (ORDER BY last_purchase_date ASC) AS r_score,
        NTILE(5) OVER (ORDER BY purchase_frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY total_monetary_investment ASC) AS m_score
    FROM CustomerBaseMetrics
)
SELECT 
    customer_unique_id,
    total_monetary_investment AS total_spent, -- Added to the visual grid for clarity
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS aggregate_rfm_score,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions / VIP'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk / Can''t Lose Them'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Hibernating / Lost'
        ELSE 'General Active Pool'
    END AS customer_behavioral_segment
FROM RFM_Scores
ORDER BY total_monetary_investment DESC -- FIXED: Column is now fully visible here!
LIMIT 15;
