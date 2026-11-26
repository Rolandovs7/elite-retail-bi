BEGIN;

CREATE TABLE dw.fact_ventas (
    txn_id bigint PRIMARY KEY,
    date_key integer NOT NULL REFERENCES dw.dim_fecha(date_key),
    customer_id bigint NOT NULL REFERENCES dw.dim_cliente(customer_id),
    product_id integer NOT NULL REFERENCES dw.dim_producto(product_id),
    store_id integer NOT NULL REFERENCES dw.dim_tienda(store_id),
    staff_id integer NOT NULL REFERENCES dw.dim_empleado(staff_id),
    payment_method text NOT NULL REFERENCES dw.dim_metodo_pago(payment_method),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price_estimated numeric(12,2) NOT NULL,
    unit_cost_estimated numeric(12,2) NOT NULL,
    sales_amount_estimated numeric(14,2) NOT NULL,
    cost_amount_estimated numeric(14,2) NOT NULL,
    gross_margin_estimated numeric(14,2) NOT NULL
);

INSERT INTO dw.fact_ventas (
    txn_id,
    date_key,
    customer_id,
    product_id,
    store_id,
    staff_id,
    payment_method,
    quantity,
    unit_price_estimated,
    unit_cost_estimated,
    sales_amount_estimated,
    cost_amount_estimated,
    gross_margin_estimated
)
SELECT
    s.txn_id::bigint,
    to_char(s.event_time::timestamp::date, 'YYYYMMDD')::integer,
    s.customer_id::bigint,
    s.product_id::integer,
    s.store_id::integer,
    s.staff_id::integer,
    s.payment_method,
    s.quantity::integer,
    p.retail_price::numeric(12,2),
    p.unit_cost::numeric(12,2),
    (s.quantity::integer * p.retail_price::numeric)::numeric(14,2),
    (s.quantity::integer * p.unit_cost::numeric)::numeric(14,2),
    (s.quantity::integer *
        (p.retail_price::numeric - p.unit_cost::numeric)
    )::numeric(14,2)
FROM staging.sales_raw_oltp s
JOIN dw.dim_producto p
    ON p.product_id = s.product_id::integer;

COMMIT;
