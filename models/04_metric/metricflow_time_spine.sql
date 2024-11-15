{{
  config(
    materialized = 'table',
    tags = ['semantic', 'metricflow']
  )
}}

{#-
  if you encounter a compilation error due to duplicated metricflow_time_spine node,
  add enabled=false in the config block above 
-#}

--Check https://docs.getdbt.com/docs/build/metricflow-time-spine
{% set start_date = var("dbt_dq_tool_start_date", "to_date('01/01/2000','mm/dd/yyyy')") -%}
{% set end_date = var("dbt_dq_tool_end_date", "to_date('01/01/2030','mm/dd/yyyy')") -%}

{%- if target.type == "bigquery" %}

  {% set start_date = var("dbt_dq_tool_start_date", "DATE(2000,01,01)") %}
  {% set end_date = var("dbt_dq_tool_end_date", "DATE(2030,01,01)") %}

{%- endif %}

with days as (

  {{ dbt_utils.date_spine('day', start_date, end_date) }}

),

final as (
    select cast(date_day as date) as date_day
    from days
)

select * from final