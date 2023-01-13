{% macro __get_where_subquery(test_model, config, sql_escape=false) %}

  {% if not test_model %}
    {{ return('') }}
  {% endif %}

  {% set relation = dq_tools.__get_relation(test_model) %}
  {% if not relation %}
    {{ return('') }}
  {% endif %}


  {% set where = config.get('where', none) %}
  {% if where is not none %}
    {%- set filtered -%}
      (select * from {{ relation }} where {{ where | replace("'", "\\'") if sql_escape else where }}) dbt_subquery
    {%- endset -%}
    {% do return(filtered) %}
  {%- else -%}
    {% do return(relation) %}
  {%- endif -%}

{% endmacro %}