{% macro __get_column_name(test_node) %}

  {%- if test_node.test_metadata is defined -%}

    {{ return(test_node.test_metadata.kwargs.column_name or test_node.test_metadata.kwargs.field) }}

  {%- endif %}

  {{ return('') }}

{% endmacro %}