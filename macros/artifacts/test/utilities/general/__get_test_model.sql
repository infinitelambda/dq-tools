{% macro __get_test_model(test_node) %}

  {% if test_node.test_metadata is defined %}

    {% set re = modules.re %}

    {#
      test_node.test_metadata.kwargs.model = "{{ get_where_subquery(source('name', 'table')) }}" or
      test_node.test_metadata.kwargs.model = "{{ get_where_subquery(ref('table')) }}"
    #}
    {% set result = re.search('\((.*?)\)', test_node.test_metadata.kwargs.model) %}
    {% if result is none %}
      {{ return(none) }}
    {% endif %}

    {#
      relation_func = "source('name', 'table')" or
      relation_func = "ref('table')" or "ref('package', 'table')"
    #}
    {% set relation_func = result.group(1) ~ ')' %}

    {% set parts = relation_func.split(',') %}
    {% if relation_func.startswith('ref') %}

      {% if parts | length > 1 %}
        {{ return(
          {
            'type': 'ref',
            'name': re.search('\'(.*?)\'', parts[1]).group(1),
            'package_name': re.search('\'(.*?)\'', parts[0]).group(1)
          }
        )}}
      {% else %}
        {{ return(
          {
            'type': 'ref',
            'name': re.search('\'(.*?)\'', parts[0]).group(1),
            'package_name': ''
          }
        )}}
      {% endif %}

    {% elif relation_func.startswith('source') and (parts | length) > 1 %}

      {{ return(
        {
          'type': 'source',
          'name': re.search('\'(.*?)\'', parts[1]).group(1),
          'source_name': re.search('\'(.*?)\'', parts[0]).group(1)
        }
      )}}

    {% endif %}

  {% endif %}

  {{ return(none) }}

{% endmacro %}