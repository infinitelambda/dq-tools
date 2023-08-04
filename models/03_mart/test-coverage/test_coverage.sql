{{
  config(
    tags = ['dq'],
  )
}}

with

test_result as (

  select  *
          ,concat(table_name, column_name) as column_id
          ,row_number() over (
            partition by invocation_id, table_name 
            order by no_of_table_columns desc) as table_column_rn

  from    {{ ref('dq_tools', 'dq_issue_log') }}

  where   coalesce(table_name, '') != ''

),

test_result_w_coverage_exclusion as (

  select  *
  from    test_result
  where   1=1
    and   {{ dq_tools.__get_test_coverage_exclusion_sql(table_name='table_name') }}

),

pre_final as (

  select      invocation_id
              ,min(check_timestamp) as check_timestamp

              --intermediate measure
              ,count(distinct column_id) as all_tested_columns
              ,sum(case when table_column_rn = 1 then no_of_table_columns else 0 end) as all_columns
              ,count(distinct table_name) as all_tested_tables
              ,max(no_of_tables) - max(ce.no_of_tables_excluded) as all_tables
              ,count(distinct test_unique_id) as test_count

              --intermediate pct measure
              ,avg(no_of_records_scanned) * 100.0 / nullif(avg(no_of_records), 0) as column_record_coverage_pct
            
  from        test_result
  cross join  (
                --to minus the excluded count to total count of tables
                select  count(distinct table_name) no_of_tables_excluded
                from    test_result_w_coverage_exclusion
              ) as ce

  where     1=1
    and     column_name is not null

    --coverage exclude by table names
    and     table_name not in (select table_name from test_result_w_coverage_exclusion)

  group by  1

),

final as (

  select  *
          --intermediate pct measure (cont)
          ,all_tested_columns * 100.0 / nullif(all_columns, 0) as column_coverage_pct
          ,all_tested_tables * 100.0 / nullif(all_tables, 0) as model_coverage_pct

          --final measure
          ,column_record_coverage_pct 
            * (all_tested_columns * 1.0 / nullif(all_columns, 0)) 
            * (all_tested_tables * 1.0 / nullif(all_tables, 0)) as coverage_pct
          ,test_count * 1.0 / all_columns as test_to_column_ratio

  from    pre_final

)

select  *
from    final