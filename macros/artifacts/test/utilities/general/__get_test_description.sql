{% macro __get_test_description(test_unique_id) %}

    {%- set test_node = graph.nodes[test_unique_id] -%}

    {%- if test_node.description is defined -%}

        {{ return(test_node.description) }}

    {%- else -%}

        {{ return('') }}

    {%- endif %}
    
{% endmacro %}
