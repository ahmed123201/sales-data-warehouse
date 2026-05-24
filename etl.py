import pandas as pd
from sqlalchemy import create_engine

# ─────────────────────────────────────────
# 1. CONNECTION
# ─────────────────────────────────────────
engine = create_engine('postgresql://postgres:YOUR_PASSWORD@localhost:5432/sales_dw')

# ─────────────────────────────────────────
# 2. EXTRACT
# ─────────────────────────────────────────
df = pd.read_csv('supermarket_sales.csv')

# ─────────────────────────────────────────
# 3. TRANSFORM
# ─────────────────────────────────────────

# -- Date
df['Date'] = pd.to_datetime(df['Date'])

# -- Branch names
df['Branch'] = df['Branch'].replace({
    'A': 'Branch A',
    'B': 'Branch B',
    'C': 'Branch C'
})

# dim_date
dim_date = df[['Date']].copy()
dim_date = dim_date.rename(columns={'Date': 'full_date'})
dim_date['year']    = dim_date['full_date'].dt.year
dim_date['month']   = dim_date['full_date'].dt.month
dim_date['week']    = dim_date['full_date'].dt.isocalendar().week
dim_date['day']     = dim_date['full_date'].dt.day
dim_date['weekday'] = dim_date['full_date'].dt.weekday
dim_date['quarter'] = dim_date['full_date'].dt.quarter
dim_date = dim_date.drop_duplicates().reset_index(drop=True)

# dim_customer
dim_customer = df[['Customer type', 'Gender', 'City']].copy()
dim_customer = dim_customer.rename(columns={
    'Customer type': 'customer_type',
    'Gender':        'gender',
    'City':          'city'
})
dim_customer = dim_customer.drop_duplicates().reset_index(drop=True)

# dim_product
dim_product = df[['Product line']].copy()
dim_product = dim_product.rename(columns={'Product line': 'product_category'})
dim_product = dim_product.drop_duplicates().reset_index(drop=True)

# dim_department
dim_department = df[['Branch']].copy()
dim_department = dim_department.rename(columns={'Branch': 'department_name'})
dim_department = dim_department.drop_duplicates().reset_index(drop=True)

# ─────────────────────────────────────────
# 4. LOAD DIMENSIONS
# ─────────────────────────────────────────
dim_date.to_sql('dim_date', engine, schema='warehouse', if_exists='append', index=False)
dim_customer.to_sql('dim_customer', engine, schema='warehouse', if_exists='append', index=False)
dim_product.to_sql('dim_product', engine, schema='warehouse', if_exists='append', index=False)
dim_department.to_sql('dim_department', engine, schema='warehouse', if_exists='append', index=False)

print("Dimensions loaded ✅")

# ─────────────────────────────────────────
# 5. READ IDs FROM DB
# ─────────────────────────────────────────
dim_customer_db   = pd.read_sql('SELECT * FROM warehouse.dim_customer', engine)
dim_product_db    = pd.read_sql('SELECT * FROM warehouse.dim_product', engine)
dim_date_db       = pd.read_sql('SELECT * FROM warehouse.dim_date', engine)
dim_department_db = pd.read_sql('SELECT * FROM warehouse.dim_department', engine)

dim_date_db['full_date'] = pd.to_datetime(dim_date_db['full_date'])

# ─────────────────────────────────────────
# 6. BUILD FACT TABLE
# ─────────────────────────────────────────
fact_sales = df.merge(
    dim_department_db[['department_id', 'department_name']],
    left_on='Branch', right_on='department_name', how='left'
)
fact_sales = fact_sales.merge(
    dim_product_db[['product_id', 'product_category']],
    left_on='Product line', right_on='product_category', how='left'
)
fact_sales = fact_sales.merge(
    dim_customer_db[['customer_id', 'customer_type', 'gender', 'city']],
    left_on=['Customer type', 'Gender', 'City'],
    right_on=['customer_type', 'gender', 'city'], how='left'
)
fact_sales = fact_sales.merge(
    dim_date_db[['date_id', 'full_date']],
    left_on='Date', right_on='full_date', how='left'
)

fact_sales_final = fact_sales[[
    'department_id', 'product_id', 'customer_id', 'date_id',
    'Quantity', 'Total', 'cogs', 'Tax 5%', 'Payment'
]].rename(columns={
    'Quantity': 'quantity',
    'Total':    'sale_price',
    'cogs':     'cost_price',
    'Tax 5%':   'tax',
    'Payment':  'payment'
})

# ─────────────────────────────────────────
# 7. LOAD FACT TABLE
# ─────────────────────────────────────────
fact_sales_final.to_sql('fact_sales', engine, schema='warehouse', if_exists='append', index=False)

print("ETL Done! ✅")
