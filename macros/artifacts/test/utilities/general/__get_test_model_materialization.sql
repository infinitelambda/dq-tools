{% macro __get_test_model_materialization(model_name) %}

  {% if execute %}
    
    {% for item in graph.nodes.values() | selectattr("name", "equalto", model_name) %}

        {% set materialized = item.config.materialized  %}

        {{ return(materialized) }}

    {% endfor %}

  {% endif %}

  {{ return('') }}

{% endmacro %}