BEGIN;

CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE dw.dim_cliente (
    customer_id bigint PRIMARY KEY,
    first_name text,
    last_name text,
    email text,
    gender text,
    city text,
    country text,
    loyalty_tier text,
    registration_date date
);

INSERT INTO dw.dim_cliente
SELECT
    customer_id::bigint,
    first_name,
    last_name,
    email,
    gender,
    city,
    country,
    loyalty_tier,
    NULLIF(registration_date, '')::date
FROM staging.customers_master;

CREATE TABLE dw.dim_categoria (
    category_id integer PRIMARY KEY,
    category_name text,
    department text,
    manager_name text
);

INSERT INTO dw.dim_categoria
SELECT category_id::integer, category_name, department, manager_name
FROM staging.product_categories;

CREATE TABLE dw.dim_proveedor (
    supplier_id integer PRIMARY KEY,
    company_name text,
    contact_person text,
    contact_email text,
    city text,
    country text,
    credit_limit numeric(12,2),
    payment_terms text
);

INSERT INTO dw.dim_proveedor
SELECT
    supplier_id::integer,
    company_name,
    contact_person,
    contact_email,
    city,
    country,
    NULLIF(credit_limit, '')::numeric(12,2),
    payment_terms
FROM staging.supplier_directory;

CREATE TABLE dw.dim_producto (
    product_id integer PRIMARY KEY,
    product_name text,
    sku_code text,
    category_id integer REFERENCES dw.dim_categoria(category_id),
    supplier_id integer REFERENCES dw.dim_proveedor(supplier_id),
    unit_cost numeric(12,2),
    retail_price numeric(12,2),
    brand text,
    color text,
    material text,
    is_active boolean
);

INSERT INTO dw.dim_producto
SELECT
    product_id::integer,
    product_name,
    sku_code,
    category_id::integer,
    supplier_id::integer,
    unit_cost::numeric(12,2),
    retail_price::numeric(12,2),
    brand,
    color,
    material,
    is_active::boolean
FROM staging.products_catalog;

CREATE TABLE dw.dim_tienda (
    store_id integer PRIMARY KEY,
    store_name text,
    store_type text,
    region text,
    manager_id integer,
    opening_year integer,
    square_footage integer
);

INSERT INTO dw.dim_tienda
SELECT
    store_id::integer,
    store_name,
    store_type,
    region,
    NULLIF(manager_id, '')::integer,
    NULLIF(opening_year, '')::integer,
    NULLIF(square_footage, '')::integer
FROM staging.store_locations;

CREATE TABLE dw.dim_empleado (
    staff_id integer PRIMARY KEY,
    staff_name text,
    job_title text,
    assigned_store_id integer REFERENCES dw.dim_tienda(store_id),
    hire_date date,
    is_full_time boolean
);

INSERT INTO dw.dim_empleado
SELECT
    staff_id::integer,
    staff_name,
    job_title,
    NULLIF(store_id, '')::integer,
    NULLIF(hire_date, '')::date,
    is_full_time::boolean
FROM staging.staff_records;

CREATE TABLE dw.dim_metodo_pago (
    payment_method text PRIMARY KEY
);

INSERT INTO dw.dim_metodo_pago
SELECT DISTINCT payment_method
FROM staging.sales_raw_oltp
WHERE payment_method IS NOT NULL AND payment_method <> '';

CREATE TABLE dw.dim_fecha (
    date_key integer PRIMARY KEY,
    full_date date UNIQUE NOT NULL,
    year integer,
    quarter integer,
    month integer,
    month_name text,
    day integer,
    day_of_week integer
);

INSERT INTO dw.dim_fecha
SELECT
    to_char(d::date, 'YYYYMMDD')::integer,
    d::date,
    extract(year FROM d)::integer,
    extract(quarter FROM d)::integer,
    extract(month FROM d)::integer,
    to_char(d, 'TMMonth'),
    extract(day FROM d)::integer,
    extract(isodow FROM d)::integer
FROM generate_series(
    DATE '2025-01-01',
    DATE '2025-12-30',
    INTERVAL '1 day'
) AS g(d);

COMMIT;
