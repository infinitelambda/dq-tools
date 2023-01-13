
{%- macro transaction_begin() -%}
  {{ return(adapter.dispatch('transaction_begin', macro_namespace = 'dq_tools')()) }}
{%- endmacro -%}

{% macro default__transaction_begin() %}
{% endmacro %}

{% macro snowflake__transaction_begin() %}
    begin;
{% endmacro %}



{%- macro transaction_commit() -%}
  {{ return(adapter.dispatch('transaction_commit', macro_namespace = 'dq_tools')()) }}
{%- endmacro -%}

{% macro default__transaction_commit() %}
{% endmacro %}

{% macro snowflake__transaction_commit() %}
    commit;
{% endmacro %}

