import streamlit as st
import pandas as pd
import plotly.express as px
import psycopg2
from streamlit.errors import StreamlitSecretNotFoundError

st.set_page_config(
    page_title="Elite Retail | Dashboard BI",
    page_icon="📊",
    layout="wide"
)

st.title("Elite Retail")
st.subheader("Dashboard de inteligencia de negocios")
st.caption(
    "Los importes monetarios son estimaciones calculadas con los precios "
    "actuales del catálogo; no representan ventas ni ganancias reales."
)


@st.cache_data(ttl=300)
def cargar_datos():
    try:
        db_config = st.secrets["db"]
    except (KeyError, StreamlitSecretNotFoundError):
        db_config = None

    if db_config:
        # Conexión en la nube: credenciales desde los secretos de Streamlit
        conexion = psycopg2.connect(
            dbname=db_config["dbname"],
            user=db_config["user"],
            password=db_config["password"],
            host=db_config["host"],
            port=db_config.get("port", 5432),
            sslmode=db_config.get("sslmode", "require")
        )
    else:
        # Conexión local en Linux Mint
        conexion = psycopg2.connect(
            dbname="elite_retail",
            user="rolando",
            host="/var/run/postgresql"
        )

    try:
        kpi = pd.read_sql_query(
            "SELECT * FROM bi.vw_kpi_general",
            conexion
        )
        mensual = pd.read_sql_query(
            "SELECT * FROM bi.vw_ventas_mensuales ORDER BY mes",
            conexion
        )
        categorias = pd.read_sql_query(
            "SELECT * FROM bi.vw_ventas_categoria ORDER BY ventas_estimadas DESC",
            conexion
        )
        tiendas = pd.read_sql_query(
            "SELECT * FROM bi.vw_ventas_tienda ORDER BY ventas_estimadas DESC",
            conexion
        )
        pagos = pd.read_sql_query(
            "SELECT * FROM bi.vw_metodo_pago ORDER BY transacciones DESC",
            conexion
        )
    finally:
        conexion.close()

    mensual["mes"] = pd.to_datetime(mensual["mes"])

    return kpi, mensual, categorias, tiendas, pagos


try:
    kpi, mensual, categorias, tiendas, pagos = cargar_datos()

    datos = kpi.iloc[0]

    st.caption("Resumen general de los datos disponibles")

    c1, c2, c3, c4 = st.columns(4)

    c1.metric(
        "Transacciones",
        f"{int(datos['transacciones']):,}"
    )
    c2.metric(
        "Unidades vendidas",
        f"{int(datos['unidades']):,}"
    )
    c3.metric(
        "Ventas estimadas",
        f"{datos['ventas_estimadas']:,.2f}"
    )
    c4.metric(
        "Margen bruto estimado",
        f"{datos['margen_bruto_estimado']:,.2f}",
        f"{datos['margen_bruto_porcentaje']:.2f}%"
    )

    st.divider()

    st.subheader("Evolución mensual")

    grafico_mensual = px.line(
        mensual,
        x="mes",
        y="ventas_estimadas",
        markers=True,
        labels={
            "mes": "Mes",
            "ventas_estimadas": "Ventas estimadas"
        },
        title="Ventas estimadas por mes"
    )
    grafico_mensual.update_layout(
        xaxis=dict(tickformat="%b %Y"),
        yaxis_tickformat=",.0f"
    )
    st.plotly_chart(grafico_mensual, use_container_width=True)

    col_izq, col_der = st.columns(2)

    with col_izq:
        st.subheader("Ventas estimadas por categoría")

        grafico_categorias = px.bar(
            categorias,
            x="ventas_estimadas",
            y="categoria",
            orientation="h",
            labels={
                "ventas_estimadas": "Ventas estimadas",
                "categoria": "Categoría"
            }
        )
        grafico_categorias.update_layout(
            yaxis={"categoryorder": "total ascending"},
            xaxis_tickformat=",.0f"
        )
        st.plotly_chart(grafico_categorias, use_container_width=True)

    with col_der:
        st.subheader("Transacciones por método de pago")

        grafico_pagos = px.pie(
            pagos,
            names="metodo_pago",
            values="transacciones",
            hole=0.45
        )
        st.plotly_chart(grafico_pagos, use_container_width=True)

    st.subheader("Comparación de tiendas")

    grafico_tiendas = px.bar(
        tiendas,
        x="tienda",
        y="ventas_estimadas",
        color="region",
        labels={
            "tienda": "Tienda",
            "ventas_estimadas": "Ventas estimadas",
            "region": "Región"
        }
    )
    grafico_tiendas.update_layout(
        xaxis_tickangle=-45,
        yaxis_tickformat=",.0f"
    )
    st.plotly_chart(grafico_tiendas, use_container_width=True)

    with st.expander("Ver tablas de datos"):
        st.markdown("**Resumen por categoría**")
        st.dataframe(categorias, use_container_width=True)

        st.markdown("**Resumen por tienda**")
        st.dataframe(tiendas, use_container_width=True)

        st.markdown("**Resumen por método de pago**")
        st.dataframe(pagos, use_container_width=True)

except Exception as error:
    st.error("No se pudo cargar el dashboard.")
    st.code(str(error))
    st.info(
        "Revisá que PostgreSQL esté activo, que la base elite_retail exista "
        "y que estés ejecutando el dashboard desde tu usuario de Linux."
    )
