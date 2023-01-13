{% macro __get_relation_ref(model_name) %}

  {% if execute %}

    {% for item in graph.nodes.values() | selectattr("name", "equalto", model_name) %}
      {% set relation -%}
        {{  item.database }}.{{ item.schema }}.{{ item.alias }}
      {%- endset %}
      {{ return(relation) }}
    {% endfor %}

  {% endif %}

  {{ return('') }}

{% endmacro %}