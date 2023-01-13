{% macro __get_to_relation(test_node) %}

  {% set to_model = (
          (test_node.test_metadata.kwargs.to if test_node.test_metadata.kwargs.to is defined else none)
      or  (test_node.test_metadata.kwargs.compare_model if test_node.test_metadata.kwargs.compare_model is defined else none)
    ) if test_node.test_metadata is defined  else none
  %}

  {% if to_model is not none %}

    {% if to_model.startswith('ref') %}
      {# to_model = ref('model') #}
      {% set to_model = to_model.split('\'')[1].strip() %}
      {{ return(dq_tools.__get_relation_ref(to_model)) }}

    {% elif to_model.startswith('source') %}

      {# to_model = source('source','table') #}
      {% set re = modules.re %}
      {% set result = re.search('\((.*?)\)', to_model) %}
      {% if result is none %}
        {{ return('') }}
      {% endif %}
      {% set result = result.group(1) %}

      {% set to_source = result.split(',')[0].strip()[1:-1] %}
      {% set to_table = result.split(',')[1].strip()[1:-1] %}
      {{ return(dq_tools.__get_relation_source(to_source, to_table)) }}

    {% endif %}

  {% endif %}

  {{ return(to_model if to_model is not none else '') }}

{% endmacro %}