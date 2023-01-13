{% macro current_timestamp() -%}
  {{ return(adapter.dispatch('current_timestamp', macro_namespace = 'dq_tools')()) }}
{%- endmacro %}

{% macro default__current_timestamp() -%}
    current_timestamp::{{ dq_tools.type_timestamp()}}
{%- endmacro %}

{% macro redshift__current_timestamp() -%}
    getdate()
{%- endmacro %}

{% macro bigquery__current_timestamp() -%}
    current_timestamp
{%- endmacro %}



{% macro current_timestamp_in_utc() -%}
  {{ return(adapter.dispatch('current_timestamp_in_utc', macro_namespace = 'dq_tools')()) }}
{%- endmacro %}

{% macro default__current_timestamp_in_utc() %}
    {{dq_tools.current_timestamp()}}
{% endmacro %}

{% macro snowflake__current_timestamp_in_utc() %}
    convert_timezone('UTC', {{dq_tools.current_timestamp()}})::{{dq_tools.type_timestamp()}}
{% endmacro %}

{% macro postgres__current_timestamp_in_utc() %}
    (current_timestamp at time zone 'utc')::{{dq_tools.type_timestamp()}}
{% endmacro %}