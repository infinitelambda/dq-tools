{{
  config(
    tags = ['dq'],
  )
}}

select  check_timestamp         as run_time,
        dq_issue_type           as analysis_name,
        table_name              as table_name,
        column_name             as column_name,
        kpi_category            as kpi_category,
        'Simple Statistics'     as indicator_category,
        no_of_records           as rows_processed,
        no_of_records_failed    as indicator_value

from    {{ ref('dq_tools', 'dq_issue_log') }}

qualify row_number() over (
  partition by  table_name,
                column_name,
                ref_table,
                ref_column,
                dq_issue_type,
                {{ dq_tools.date_trunc('day', 'check_timestamp') }}
  order by check_timestamp desc
) = 1