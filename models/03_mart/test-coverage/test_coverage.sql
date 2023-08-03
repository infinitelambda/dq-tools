{{
  config(
    materialized = 'incremental',
    unique_key = ['invocation_id'],
    on_schema_change = 'append_new_columns',
    full_refresh = var('dbt_dq_tool_full_refresh', false)
  )
}}

with

test_result as (

  select  *
          ,row_number() over (
            partition by invocation_id, table_name 
            order by no_of_table_columns desc) as table_column_rn

  from    {{ ref('dq_tools', 'dq_issue_log') }}

  where   1=1
  {% if is_incremental() %}
    and   invocation_id not in (select invocation_id from {{ this }})
  {% endif %}

),

final as (

  select    invocation_id
            ,min(check_timestamp) as check_timestamp
          
            --intermediate measure
            ,count(distinct table_name, column_name) as all_tested_columns
            ,sum(case when table_column_rn = 1 then no_of_table_columns else 0 end) as all_columns
            ,count(distinct table_name) as all_tested_tables
            ,max(no_of_tables) as all_tables
            ,count(distinct test_unique_id) as test_count

            --intermediate pct measure
            ,avg(no_of_records_scanned) * 100.0 / nullif(avg(no_of_records), 0) as column_record_coverage_pct
            ,all_tested_columns * 100.0 / nullif(all_columns, 0) as column_coverage_pct
            ,all_tested_tables * 100.0 / nullif(all_tables, 0) as model_coverage_pct

            --final measure
            ,column_record_coverage_pct 
              * (column_coverage_pct / 100.0) 
              * (model_coverage_pct / 100.0) as coverage_pct
            ,test_count * 1.0 / all_columns as test_to_column_ratio
            
  from      test_result

  where     1=1
    and     column_name is not null
    {# and     {{ dbt_sli.get_sql_test_coverage_exclude(
              package_name='m.package_name',
              model_path='m.model_path'
            ) }} #}

  group by  1

)

select  *
from    final