CREATE SCHEMA IF NOT EXISTS bi;

CREATE OR REPLACE VIEW bi.vw_kpi_general AS
SELECT
    count(*) AS transacciones,
    sum(f.quantity) AS unidades,
    sum(f.sales_amount_estimated) AS ventas_estimadas,
    sum(f.cost_amount_estimated) AS costos_estimados,
    sum(f.gross_margin_estimated) AS margen_bruto_estimado,
    round(
        100 * sum(f.gross_margin_estimated)
        / NULLIF(sum(f.sales_amount_estimated), 0),
        2
    ) AS margen_bruto_porcentaje
FROM dw.fact_ventas f;

CREATE OR REPLACE VIEW bi.vw_ventas_mensuales AS
SELECT
    date_trunc('month', d.full_date)::date AS mes,
    count(*) AS transacciones,
    sum(f.quantity) AS unidades,
    sum(f.sales_amount_estimated) AS ventas_estimadas,
    sum(f.cost_amount_estimated) AS costos_estimados,
    sum(f.gross_margin_estimated) AS margen_bruto_estimado
FROM dw.fact_ventas f
JOIN dw.dim_fecha d ON d.date_key = f.date_key
GROUP BY date_trunc('month', d.full_date)::date;

CREATE OR REPLACE VIEW bi.vw_ventas_categoria AS
SELECT
    c.category_name AS categoria,
    count(*) AS transacciones,
    sum(f.quantity) AS unidades,
    sum(f.sales_amount_estimated) AS ventas_estimadas,
    sum(f.cost_amount_estimated) AS costos_estimados,
    sum(f.gross_margin_estimated) AS margen_bruto_estimado
FROM dw.fact_ventas f
JOIN dw.dim_producto p ON p.product_id = f.product_id
JOIN dw.dim_categoria c ON c.category_id = p.category_id
GROUP BY c.category_name;

CREATE OR REPLACE VIEW bi.vw_ventas_tienda AS
SELECT
    t.store_name AS tienda,
    t.region AS region,
    count(*) AS transacciones,
    sum(f.quantity) AS unidades,
    sum(f.sales_amount_estimated) AS ventas_estimadas,
    sum(f.gross_margin_estimated) AS margen_bruto_estimado
FROM dw.fact_ventas f
JOIN dw.dim_tienda t ON t.store_id = f.store_id
GROUP BY t.store_name, t.region;

CREATE OR REPLACE VIEW bi.vw_metodo_pago AS
SELECT
    f.payment_method AS metodo_pago,
    count(*) AS transacciones,
    sum(f.sales_amount_estimated) AS ventas_estimadas,
    sum(f.gross_margin_estimated) AS margen_bruto_estimado
FROM dw.fact_ventas f
GROUP BY f.payment_method;
