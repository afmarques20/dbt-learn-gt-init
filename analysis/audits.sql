-- Compare row counts
{% set old_relation = adapter.get_relation(
      database = target.database,
      schema = "dbt_amarques",
      identifier = "customer_orders_legacy"
) -%}

{% set dbt_relation = ref('fct_customer_orders') %}

{{ audit_helper.compare_row_counts(
    a_relation = old_relation,
    b_relation = dbt_relation
) }}



-- Compare column values
{% set old_relation = adapter.get_relation(
      database = target.database,
      schema = "dbt_amarques",
      identifier = "customer_orders_legacy"
) -%}

{% set dbt_relation = ref('fct_customer_orders') %}


{%if execute %}
{{ audit_helper.compare_all_columns(
    a_relation = old_relation,
    b_relation = dbt_relation,
    primary_key = "order_id",
    exclude_columns = ["nvsr", "clv_bad", "fdos", "customer_first_name", "customer_last_name"]
) }}
{% endif %}
