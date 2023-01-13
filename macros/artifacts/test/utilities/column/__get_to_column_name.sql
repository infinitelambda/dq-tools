{% macro __get_to_column_name(test_node) %}

  {%- if test_node.test_metadata is defined
        and (
          test_node.test_metadata.kwargs.to is defined
          or test_node.test_metadata.kwargs.compare_model is defined
        )
        and test_node.test_metadata.kwargs.field is defined -%}

    {{ return(test_node.test_metadata.kwargs.field) }}

  {%- endif %}

  {{ return('') }}

{% endmacro %}