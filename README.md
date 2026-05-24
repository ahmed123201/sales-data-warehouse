# sales-data-warehouse

## Overview
End-to-end Data Warehouse project built with PostgreSQL and Python.

## Technologies
- PostgreSQL
- Python (Pandas, SQLAlchemy)

## Architecture
CSV → Python ETL → PostgreSQL (Star Schema) 

## Schema
- dim_date
- dim_customer
- dim_product
- dim_department
- fact_sales

## How to Run
1. Create database: `sales_dw`
2. Run `schema.sql` in pgAdmin
3. Run `etl.py`
