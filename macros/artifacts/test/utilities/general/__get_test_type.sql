{% macro __get_test_type(test_node) %}

  {%- set test_type = '' -%}

  {%- if test_node.test_metadata is defined -%}
    {%- set test_type = 'generic' -%}
  {%- elif test_node.name is defined -%}
    {%- set test_type = 'singular' -%}
  {%- endif %}

  {{ return(test_type) }}

{% endmacro %}