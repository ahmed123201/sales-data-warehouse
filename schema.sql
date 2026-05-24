CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE warehouse.dim_date (
    date_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_date DATE,
    year      SMALLINT,
    month     SMALLINT,
    week      SMALLINT,
    day       SMALLINT,
    quarter   SMALLINT,
    weekday   SMALLINT
);

CREATE TABLE warehouse.dim_customer (
    customer_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_type TEXT,
    gender        TEXT,
    city          TEXT
);

CREATE TABLE warehouse.dim_product (
    product_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_category TEXT
);

CREATE TABLE warehouse.dim_department (
    department_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name TEXT,
    sub_department  TEXT
);

CREATE TABLE warehouse.fact_sales (
    sale_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id   INT REFERENCES warehouse.dim_customer(customer_id),
    product_id    INT REFERENCES warehouse.dim_product(product_id),
    date_id       INT REFERENCES warehouse.dim_date(date_id),
    department_id INT REFERENCES warehouse.dim_department(department_id),
    quantity      INT,
    sale_price    DECIMAL,
    cost_price    DECIMAL,
    tax           DECIMAL,
    payment       TEXT,
    net_profit    DECIMAL GENERATED ALWAYS AS
                  ((sale_price - cost_price) * quantity) STORED
);
