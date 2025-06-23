{% macro __get_row_condition(test_node) %}

  {%- set row_condition = none -%}

  {%- if test_node.test_metadata.kwargs.row_condition is defined -%}
    {%- set row_condition = test_node.test_metadata.kwargs.row_condition-%}
  {%- endif %}

  {{ return(row_condition) }}

{% endmacro %}
