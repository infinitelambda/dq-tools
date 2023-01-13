{% macro __get_test_name(test_node) %}

  {%- if test_node.test_metadata is defined -%}

    {{ return(test_node.test_metadata.name) }}

  {%- elif test_node.name is defined -%}

    {{ return(test_node.name) }}

  {%- endif %}

  {{ return('') }}

{% endmacro %}