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
      relation_func = "ref('table')" or "ref('package', 'table')" or "ref('package', 'table', v='1')" or "ref('table', v='1')"
    #}
    {% set relation_func = result.group(1) ~ ')' %}
    {% set parts = relation_func.split(',') %}
    {% if relation_func.startswith('ref') %}
      {% if parts | length > 1 %}
        {% if 'version=' in relation_func %}
          {% if parts | length == 2 %}
            {{ return(
            {
              'type': 'ref',
              'package_name': '',
              'name': re.search('\'(.*?)\'', parts[0]).group(1),
              'version': re.search('version=\'(.*?)\'', parts[1]).group(1)
            }
          )}}
          {% elif parts | length == 3 %}
          {{ return(
            {
              'type': 'ref',
              'package_name': re.search('\'(.*?)\'', parts[0]).group(1),
              'name': re.search('\'(.*?)\'', parts[1]).group(1),
              'version': re.search('version=\'(.*?)\'', parts[2]).group(1)
            }
          )}}
          {% endif %}  
        {% else %}
          {{ return(
            {
              'type': 'ref',
              'package_name': re.search('\'(.*?)\'', parts[0]).group(1),
              'name': re.search('\'(.*?)\'', parts[1]).group(1)
            }
          )}}
        {% endif %}
      {% else %}
        {{ return(
          {
            'type': 'ref',
            'package_name': '',
            'name': re.search('\'(.*?)\'', parts[0]).group(1)
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
