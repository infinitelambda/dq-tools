{% macro __get_relation_ref(model_name) %}

  {% if execute %}

    {% for item in graph.nodes.values() | selectattr("name", "equalto", model_name) %}
      {% set relation = adapter.get_relation(
                          database=item.database,
                          schema=item.schema,
                          identifier=item.alias or item.name) %}
      {{ return(relation) }}
    {% endfor %}

  {% endif %}

  {{ return('') }}

{% endmacro %}