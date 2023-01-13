{% macro date_trunc(datepart, date) -%}
  {{ return(adapter.dispatch('date_trunc', 'dq_tools') (datepart, date)) }}
{%- endmacro %}

{% macro default__date_trunc(datepart, date) -%}
  date_trunc('{{datepart}}', {{date}})
{%- endmacro %}

{% macro bigquery__date_trunc(datepart, date) -%}
  date_trunc({{date}}, {{ datepart | upper }})
{%- endmacro %}