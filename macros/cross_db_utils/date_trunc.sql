{% macro date_trunc(date, datepart) -%}
  {{ return(adapter.dispatch('date_trunc', 'dq_tools') (date, datepart)) }}
{%- endmacro %}

{% macro default__date_trunc(date, datepart) -%}
  date_trunc('{{datepart}}', {{date}})
{%- endmacro %}

{% macro bigquery__date_trunc(date, datepart) -%}
  date_trunc({{date}}, {{ datepart | upper }})
{%- endmacro %}
