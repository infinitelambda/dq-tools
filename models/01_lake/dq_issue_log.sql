{{
  config(
    materialized = 'incremental',
    on_schema_change = 'append_new_columns',
    full_refresh = false
  )
}}

--append new column
--disabled full refresh --> full refresh required manual droping

select   cast(check_timestamp       as {{ dbt.type_timestamp() }}) as check_timestamp
        ,cast(table_name            as {{ dbt.type_string() }}) as table_name
        ,cast(column_name           as {{ dbt.type_string() }}) as column_name
        ,cast(ref_table             as {{ dbt.type_string() }}) as ref_table
        ,cast(ref_column            as {{ dbt.type_string() }}) as ref_column
        ,cast(dq_issue_type         as {{ dbt.type_string() }}) as dq_issue_type
        ,cast(invocation_id         as {{ dbt.type_string() }}) as invocation_id
        ,cast(dq_model              as {{ dbt.type_string() }}) as dq_model
        ,cast(severity              as {{ dbt.type_string() }}) as severity
        ,cast(kpi_category          as {{ dbt.type_string() }}) as kpi_category
        ,cast(no_of_records         as {{ dbt.type_int() }}) as no_of_records
        ,cast(no_of_records_failed  as {{ dbt.type_int() }}) as no_of_records_failed
        ,cast(no_of_table_columns   as {{ dbt.type_int() }}) as no_of_table_columns

where   1=0