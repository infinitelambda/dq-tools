{% macro store_test_results(results, batch=100) -%}

  {%- set enable_store_result = var('dq_tools_enable_store_test_results', false) -%}
  {%- if var('dbt_test_results_to_db', false) or not execute %}
    {# Compatible to prev funcs to avoid duplicates of test results captured #}
    {% set enable_store_result = false %}
  {% endif -%}
  {%- if not enable_store_result or not execute %}
    {{ log("Ignored as `store_test_results` functionality is NOT being enabled", true) if execute }}
    {{ return('') }}
  {% endif -%}


  {%- set test_results = [] %}
  {%- for result in results if result.node.resource_type | lower == 'test' and result.status | lower != 'error' %}
    {%- set test_results = test_results.append(result) -%}
  {% endfor -%}

  {%- if (test_results | length) == 0 %}
    {{ log("Found no test results to process.", true) if execute }}
    {{ return('') -}}
  {% endif -%}

  {%- set log_tbl %} {{ target.database }}.{{ var('dbt_dq_tool_schema') }}.dq_issue_log {% endset -%}

  {{ log("Centralizing " ~ test_results|length ~ " test results in " + log_tbl, true) if execute -}}
  {{- dq_tools.create_dq_issue_log() -}}

  {% for i in range(0, (test_results | length), batch) -%}

    {% set chunk = test_results[i:i+batch] %}
    insert into {{ log_tbl }}
    (
       check_timestamp
      ,table_name
      ,column_name
      ,ref_table
      ,ref_column
      ,dq_issue_type
      ,invocation_id
      ,dq_model
      ,severity
      ,kpi_category
      ,no_of_records
      ,no_of_records_failed
    )

    with logs as (

    {%- for result in chunk %}

      {{ dq_tools.__select_test_result(result) }}
      {{ "union all" if not loop.last }}

    {%- endfor -%}
    )

    select    _timestamp as check_timestamp
              ,table_name
              ,column_name
              ,ref_table
              ,ref_column
              ,dq_issue_type
              ,dbt_invocation_id as invocation_id
              ,dq_model
              ,test_severity_config as severity
              ,test_kpi_category_config as kpi_category
              ,no_of_records
              ,no_of_records_failed

    from      logs;

  {% endfor -%}

{%- endmacro %}