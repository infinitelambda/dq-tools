{% macro __get_relation_ref(model_name) %}

  {% if execute %}

    {% for item in graph.nodes.values() | selectattr("name", "equalto", model_name) %}
      {% set relation = adapter.get_relation(
                          database=item.database,
                          schema=item.schema,
                          identifier=item.alias or item.name) %}

      {% if relation is none and item.defer_relation %}
        {% set relation = adapter.get_relation(
                            database=item.defer_relation.database,
                            schema=item.defer_relation.schema,
                            identifier=item.defer_relation.alias or item.defer_relation.name) %}
      {% endif %}
      
      {{ return(relation) }}
    {% endfor %}

  {% endif %}

  {{ return('') }}

{% endmacro %}