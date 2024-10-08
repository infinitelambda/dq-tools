{% macro __get_relation_source(source_name, table_name) %}

  {% if execute %}

    {% for item in graph.sources.values() | selectattr("source_name", "equalto", source_name) %}
      {% if item.name == table_name %}
      
        {{ return(source(source_name, table_name)) }}

      {% endif %}
    {% endfor %}

  {% endif %}

  {{ return('') }}

{% endmacro %}