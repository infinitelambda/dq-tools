{% macro __get_dq_issue_type(test_node) %}

  {% if test_node.test_metadata is defined
    and test_node.test_metadata.kwargs.dq_issue_type is defined %}
    {# 1. Find value in kwargs.dq_issue_type -#}
    {{ return(test_node.test_metadata.kwargs.dq_issue_type) }}
  {% endif %}

  {% if test_node.config.meta.dq_issue_type is defined %}
    {# 2. Find value in meta.dq_issue_type -#}
    {{ return(test_node.config.meta.dq_issue_type) }}
  {% endif %}

  {# 3. Auto-assign DQ issue type -#}
  {{ return(dq_tools.__auto_dq_issue_type(test_node)) }}

{% endmacro %}


{% macro __auto_dq_issue_type(test_node) %}

  {% if dq_tools.__get_test_type(test_node) == 'singular' %}
    {{ return('business test') }}
  {% endif %}

  {%- set test_name = dq_tools.__get_test_name(test_node) -%}

  {% if test_name.endswith('_where_db') %}
    {% set test_name = test_name[0:-9] %}
  {% endif %}
  {% if test_name.endswith('_db') %}
    {% set test_name = test_name[0:-3] %}
  {% endif %}


  {{ return(test_name | replace('_', ' ')) }}

{% endmacro %}