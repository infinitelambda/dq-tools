{% macro __get_relation(test_model) %}

  {% if execute %}
    {% if test_model.type == 'ref' %}

      {{ return(dq_tools.__get_relation_ref(test_model.name)) }}

    {% elif test_model.type == 'source' %}

      {{ return(dq_tools.__get_relation_source(test_model.source_name, test_model.name)) }}

    {% endif %}

  {% endif %}

  {{ return('') }}

{% endmacro %}