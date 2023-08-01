{% macro dq_exec_custom_test_db(business_test_code, business_test_comment, sql_cmd, severity_level) %}

{% set severity_level = kwargs.get('severity_level', 'warn') %}
{% set sql_cmd_c = sql_cmd | replace('\'','\'\'') %}
{% set p_invocation_id = invocation_id %}


{{
    config(
      severity = severity_level
    )
}}

{% set sql_cmd %}

    begin;

    insert into {{ var('dbt_dq_tool_database', target.database) }}.DBT.DQ_BUSINESS_CHECK_LOG (business_check_code, business_check_comment, check_timestamp, no_of_records, invocation_id, dq_model, severity, sql_cmd)

    with subsql as
    (
    -- custom query
    {{ sql_cmd }}
    )

    select
            -- each business check has to have a unique business_test_code. you can filter on in later
            '{{ business_test_code }}' as business_test_code,
            -- explain the purpose of the test, this will be shown in the report
            '{{ business_test_comment }}' as business_test_comment,
            to_timestamp_ntz(convert_timezone('UTC', current_timestamp)) check_timestamp,
            count(*) no_of_records,
            '{{ p_invocation_id }}' invocation_id,
            '{{ this }}' dq_model,
            '{{ severity_level }}' severity,
            '{{ sql_cmd_c }}' sql_cmd
from subsql
having no_of_records > 0;

commit;

{% endset %}


{% if execute %}
   {% do run_query(sql_cmd) %}

   select 1
   from {{ var('dbt_dq_tool_database', target.database) }}.DBT.DQ_BUSINESS_CHECK_LOG
   where invocation_id='{{ p_invocation_id }}'
         and dq_model = '{{ this }}'
{% endif %}

{% endmacro %}
