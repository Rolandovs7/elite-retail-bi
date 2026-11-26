CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.customers_master (
    customer_id text, first_name text, last_name text, email text,
    phone text, date_of_birth text, gender text, street_address text,
    city text, postcode text, country text, loyalty_tier text,
    registration_date text
);

CREATE TABLE IF NOT EXISTS staging.product_categories (
    category_id text, category_name text, department text,
    manager_name text
);

CREATE TABLE IF NOT EXISTS staging.products_catalog (
    product_id text, product_name text, sku_code text,
    category_id text, supplier_id text, unit_cost text,
    retail_price text, weight_kg text, is_active text,
    reorder_level text, brand text, color text, material text
);

CREATE TABLE IF NOT EXISTS staging.sales_raw_oltp (
    txn_id text, customer_id text, product_id text,
    store_id text, staff_id text, quantity text,
    payment_method text, event_time text
);

CREATE TABLE IF NOT EXISTS staging.staff_records (
    staff_id text, staff_name text, job_title text,
    store_id text, hire_date text, is_full_time text
);

CREATE TABLE IF NOT EXISTS staging.store_locations (
    store_id text, store_name text, store_type text,
    region text, manager_id text, opening_year text,
    square_footage text
);

CREATE TABLE IF NOT EXISTS staging.supplier_directory (
    supplier_id text, company_name text, contact_person text,
    contact_email text, phone_number text, address text,
    city text, country text, credit_limit text, payment_terms text
);
