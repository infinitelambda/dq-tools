{% macro __get_kpi_categorize(test_node) %}

  {% if test_node.test_metadata is defined
    and test_node.test_metadata.kwargs.kpi_category is defined %}
    {# 1. Find value in kwargs.kpi_category -#}
    {{ return(test_node.test_metadata.kwargs.kpi_category) }}
  {% endif %}

  {% if test_node.config.meta.kpi_category is defined %}
    {# 2. Find value in meta.kpi_category -#}
    {{ return(test_node.config.meta.kpi_category) }}
  {% endif %}

  {# 3. Auto-assign KPI -#}
  {{ return(dq_tools.__auto_categorize_kpi(test_node)) }}

{% endmacro %}


{% macro __auto_categorize_kpi(test_node) %}

  {% if dq_tools.__get_test_type(test_node) == 'singular' %}
    {{ return('Validity') }} {# Should be same as expression_is_true default config -#}
  {% endif %}

  {%- set test_name = dq_tools.__get_test_name(test_node) -%}
  {# Accuracy #}
  {% set accuracies = ['accepted_values'] %}
  {% for item in accuracies if item in test_name %}
    {{ return('Accuracy') }}
  {% endfor %}

  {# Consistency #}
  {% set consistencies = ['equal_rowcount','equality','relationships'] %}
  {% for item in consistencies if item in test_name %}
    {{ return('Consistency') }}
  {% endfor %}

  {# Completeness #}
  {% set completenesses = ['not_null'] %}
  {% for item in completenesses if item in test_name %}
    {{ return('Completeness') }}
  {% endfor %}

  {# Timeliness #}
  {% set timelinesses = ['recency'] %}
  {% for item in timelinesses if item in test_name %}
    {{ return('Timeliness') }}
  {% endfor %}

  {# Validity #}
  {% set validities = ['expression_is_true'] %}
  {% for item in validities if item in test_name %}
    {{ return('Validity') }}
  {% endfor %}

  {# Uniqueness #}
  {% set uniquenesses = ['unique'] %}
  {% for item in uniquenesses if item in test_name %}
    {{ return('Uniqueness') }}
  {% endfor %}

  {{ return('Other') }}

{% endmacro %}