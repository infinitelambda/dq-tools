{% macro store_test_results(results, log_tbl=ref('dq_tools', 'dq_issue_log'), batch=1000) -%}

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
  {%- for result in results if result.node.resource_type | lower == 'test' and result.status | lower not in ['error', 'skipped'] %}
    {%- set test_results = test_results.append(result) -%}
  {% endfor -%}

  {%- if (test_results | length) == 0 %}
    {{ log("Found no test results to process.", true) if execute }}
    {{ return('') -}}
  {% endif -%}

  {{ log("Centralizing " ~ test_results|length ~ " test results in " ~ log_tbl, true) if execute -}}

  {% set no_of_tables = dq_tools.__get_tables_from_graph() | length %}
  {% for i in range(0, (test_results | length), batch) -%}
  
    {% set chunk_items = test_results[i:i+batch] %}
    insert into {{ log_tbl }}
    (
       check_timestamp
      ,table_name
      ,table_query
      ,column_name
      ,ref_table
      ,ref_column
      ,dq_issue_type
      ,invocation_id
      ,dq_model
      ,severity
      ,kpi_category
      ,no_of_records
      ,no_of_records_scanned
      ,no_of_records_failed
      ,no_of_table_columns
      ,no_of_tables
      ,test_unique_id
      ,test_description
    )

    with logs as (

    {%- for result in chunk_items %}
    
      {{ dq_tools.__select_test_result(result) }}
      {{ "union all" if not loop.last }}

    {%- endfor -%}
    )

    select    _timestamp as check_timestamp
              ,table_name
              ,table_query
              ,column_name
              ,ref_table
              ,ref_column
              ,dq_issue_type
              ,dbt_invocation_id as invocation_id
              ,dq_model
              ,test_severity_config as severity
              ,test_kpi_category_config as kpi_category
              ,no_of_records
              ,no_of_records_scanned
              ,no_of_records_failed
              ,no_of_table_columns
              ,{{ no_of_tables }} as no_of_tables
              ,test_unique_id
              ,test_description

    from      logs;

  {% endfor -%}

{%- endmacro %}