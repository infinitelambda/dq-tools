{% test recency_db(model, datepart, interval) %}

{% set column_name = kwargs.get('column_name', kwargs.get('field')) %}
{% set severity_level = kwargs.get('severity_level', 'warn') %}
{% set kpi_category = kwargs.get('kpi_category', 'Timeliness') %}
{% set p_invocation_id = invocation_id %}
{% set model_text = model | replace("'", "''") %}


{% if kpi_category not in ['Accuracy', 'Consistency', 'Completeness', 'Timeliness', 'Validity', 'Uniqueness'] %}
    {% set kpi_category = 'Other'%}
{% endif %}



{{
    config(
      severity = severity_level
    )
}}

{% set sql_cmd %}

   {{ dq_tools.transaction_begin() }}

    insert into {{ var('dbt_dq_tool_database', target.database) }}.{{var('dbt_dq_tool_schema', target.schema)}}.dq_issue_log (check_timestamp, table_name, column_name, dq_issue_type, invocation_id, dq_model, severity, kpi_category, no_of_records, no_of_records_failed)
    (
      with max_date as
      (
         select
         max({{column_name}}) max_date_value
         from {{model}}
      )

      select
            {{ dq_tools.current_timestamp() }} check_timestamp
         , '{{ model_text }}' table_name
         , '{{ column_name }}' column_name
         , 'recency' dq_issue_type

         , '{{ p_invocation_id }}' invocation_id
         , '{{ this }}' dq_model
         , '{{ severity_level }}' severity
         , '{{ kpi_category }}' kpi_category
         , 1 no_of_records
         , case when max_date_value >= {{ dq_tools.dateadd(datepart, interval * -1, dq_tools.current_timestamp()) }} then 0 else 1 end no_of_records_failed
      from max_date
    );

    {{ dq_tools.transaction_commit() }}
{% endset %}

{% if var('dbt_test_results_to_db', False) %}
   {% do run_query(sql_cmd) %}
{% endif %}
      {%- set threshold = dq_tools.dateadd(datepart, interval * -1, dq_tools.current_timestamp()) -%}
      with max_date as
      (
         select   max({{column_name}}) max_date_value
         from     {{model}}
      )
      select   max_date_value
               ,{{ threshold }} as threshold
      from     max_date
      where    max_date_value < {{ threshold }}


{% endtest %}
