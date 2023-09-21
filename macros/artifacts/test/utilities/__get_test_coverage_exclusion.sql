{% macro __get_test_coverage_exclusion(rule=var('dbt_dq_tool_test_coverage_exclusion', {})) %}

  {% set databases = [] %}
  {% for rule in rule.get('by_database', []) %}
    {% do databases.append(generate_database_name(rule)) %}
  {% endfor %}

  {% set schemas = [] %}
  {% for rule in rule.get('by_schema', []) %}
    {% do schemas.append(generate_schema_name(rule)) %}
  {% endfor %}

  {% set tables = [] %}
  {% for rule in rule.get('by_table', []) %}
    {% do tables.append(generate_alias_name(rule)) %}
  {% endfor %}

  {{ return({
    "databases": databases,
    "schemas": schemas,
    "tables": tables
  }) }}

{% endmacro %}


{% macro __get_test_coverage_exclusion_sql(table_name='table_name') %}

  {% set rule = dq_tools.__get_test_coverage_exclusion() %}
  
  {% set query -%}
    (
      {% if rule.databases -%}
        (
          lower(split({{ table_name }}, '.')[0]) in (
            {%- for rule in rule.databases -%}
              '{{ rule | lower }}' {% if not loop.last %},{% endif %}
            {%- endfor -%}
          )
        )
      {%- else -%}
        --no database exclusions
      {%- endif %}
      
      {% if rule.schemas -%}
        {% if rule.databases %}or{% endif %}
        (
          lower(split({{ table_name }}, '.')[1]) in (
            {%- for rule in rule.schemas -%}
              '{{ rule | lower }}' {% if not loop.last %},{% endif %}
            {%- endfor -%}
          )
        )
      {%- else -%}
        --no schema exclusions
      {%- endif %}
      
      {% if rule.tables -%}
        {% if rule.databases or rule.schemas %}or{% endif %}
        (
          lower(split({{ table_name }}, '.')[2]) in (
            {%- for rule in rule.tables -%}
              '{{ rule | lower }}' {% if not loop.last %},{% endif %}
            {%- endfor -%}
          )
        )
      {%- else -%}
        --no table exclusions
      {%- endif %}
      
      {% if not rule.databases and not rule.schemas and not rule.tables -%}
        0=1
      {%- endif %}
    )
  {%- endset %}

  {{ return(query) }}

{% endmacro %}