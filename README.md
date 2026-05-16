# Olist E-Commerce Delivery Performance Analysis

End-to-end SQL analysis of Brazil's largest e-commerce dataset (100,000+ orders) to identify delivery failures, geographic risk patterns, revenue at risk, and seller-level accountability gaps.

**[Live Tableau Dashboard →](https://public.tableau.com/app/profile/kumar.saksham2703/viz/OlistDeliveryPerformanceAnalysis_17789432992130/OlistDeliverryAnalysis)**

---

![Dashboard Preview](Analysis.png)


---

## Business Problem
Olist operates across all Brazilian states with sellers concentrated in the Southeast. No structured system existed to identify which sellers consistently deliver late, quantify the revenue and satisfaction impact of delays, or flag geographic regions with disproportionate late rates.

---

## Key Findings

| Metric | Finding |
|--------|---------|
| Overall late delivery rate | 8.11% (7,826 of 96,470 orders) |
| Review score — On Time | 4.29 / 5 |
| Review score — Late | 2.57 / 5 (40% collapse) |
| Worst state late rate | AL — 23.93% |
| Top seller revenue at risk | R$26,524 across 128 late orders |
| Black Friday delay spike | Nov 2017 — 14.31% late rate |

---

## Technical Approach

**Database:** 7-table normalized PostgreSQL schema covering orders, customers, sellers, products, payments, reviews, and geolocation

**SQL Techniques:**
- Window functions for percentage calculations across groups
- CTEs for multi-step analysis
- CASE-based risk tier classification (High / Medium / Low)
- Multi-table JOINs across 5+ tables
- EXTRACT and EPOCH for delay duration calculations
- Master VIEW creation for Tableau integration

**Analysis Sections:**
1. Data quality checks and null handling
2. Overall delivery performance metrics
3. Monthly delay trend analysis
4. Geographic analysis by customer state
5. Business impact — review score vs delivery status
6. Revenue at risk by seller
7. Seller risk scoring

---

# Olist E-Commerce Delivery Performance Analysis

End-to-end SQL analysis of Brazil's largest e-commerce dataset (100,000+ orders) to identify delivery failures, geographic risk patterns, revenue at risk, and seller-level accountability gaps.

**[Live Tableau Dashboard →](https://public.tableau.com/app/profile/kumar.saksham2703/viz/OlistDeliveryPerformanceAnalysis_17789432992130/OlistDeliverryAnalysis)**

---

## Business Problem
Olist operates across all Brazilian states with sellers concentrated in the Southeast. No structured system existed to identify which sellers consistently deliver late, quantify the revenue and satisfaction impact of delays, or flag geographic regions with disproportionate late rates.

---

## Key Findings

| Metric | Finding |
|--------|---------|
| Overall late delivery rate | 8.11% (7,826 of 96,470 orders) |
| Review score — On Time | 4.29 / 5 |
| Review score — Late | 2.57 / 5 (40% collapse) |
| Worst state late rate | AL — 23.93% |
| Top seller revenue at risk | R$26,524 across 128 late orders |
| Black Friday delay spike | Nov 2017 — 14.31% late rate |

---

## Technical Approach

**Database:** 7-table normalized PostgreSQL schema covering orders, customers, sellers, products, payments, reviews, and geolocation

**SQL Techniques:**
- Window functions for percentage calculations across groups
- CTEs for multi-step analysis
- CASE-based risk tier classification (High / Medium / Low)
- Multi-table JOINs across 5+ tables
- EXTRACT and EPOCH for delay duration calculations
- Master VIEW creation for Tableau integration

**Analysis Sections:**
1. Data quality checks and null handling
2. Overall delivery performance metrics
3. Monthly delay trend analysis
4. Geographic analysis by customer state
5. Business impact — review score vs delivery status
6. Revenue at risk by seller
7. Seller risk scoring

---

## Project Structure# Olist E-Commerce Delivery Performance Analysis

End-to-end SQL analysis of Brazil's largest e-commerce dataset (100,000+ orders) to identify delivery failures, geographic risk patterns, revenue at risk, and seller-level accountability gaps.

**[Live Tableau Dashboard →](https://public.tableau.com/app/profile/kumar.saksham2703/viz/OlistDeliveryPerformanceAnalysis_17789432992130/OlistDeliverryAnalysis)**

---

## Business Problem
Olist operates across all Brazilian states with sellers concentrated in the Southeast. No structured system existed to identify which sellers consistently deliver late, quantify the revenue and satisfaction impact of delays, or flag geographic regions with disproportionate late rates.

---

## Key Findings

| Metric | Finding |
|--------|---------|
| Overall late delivery rate | 8.11% (7,826 of 96,470 orders) |
| Review score — On Time | 4.29 / 5 |
| Review score — Late | 2.57 / 5 (40% collapse) |
| Worst state late rate | AL — 23.93% |
| Top seller revenue at risk | R$26,524 across 128 late orders |
| Black Friday delay spike | Nov 2017 — 14.31% late rate |

---

## Technical Approach

**Database:** 7-table normalized PostgreSQL schema covering orders, customers, sellers, products, payments, reviews, and geolocation

**SQL Techniques:**
- Window functions for percentage calculations across groups
- CTEs for multi-step analysis
- CASE-based risk tier classification (High / Medium / Low)
- Multi-table JOINs across 5+ tables
- EXTRACT and EPOCH for delay duration calculations
- Master VIEW creation for Tableau integration

**Analysis Sections:**
1. Data quality checks and null handling
2. Overall delivery performance metrics
3. Monthly delay trend analysis
4. Geographic analysis by customer state
5. Business impact — review score vs delivery status
6. Revenue at risk by seller
7. Seller risk scoring

---

## Project Structure

**sql/**
- olist_analysis.sql

**results/**
- overall_late_rate.csv
- monthly_delay_trend.csv
- late_order_rate_by_state.csv
- late_orders_by_state.csv
- late_vs_ontime_reviews.csv
- revenue_at_risk_from_late_sellers.csv
- worst_sellers_delay.csv

---

## Dataset
**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)  
**Size:** 100,000+ orders, 2016–2018  
**Tables:** 8 relational tables

---

## Tools
- PostgreSQL — data modeling and analysis
- Tableau Public — interactive dashboard
- Git — version control
