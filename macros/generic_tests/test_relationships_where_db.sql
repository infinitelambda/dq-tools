{% test relationships_where_db(model, to, field) %}

{% set column_name = kwargs.get('column_name', kwargs.get('from')) %}
{% set from_condition = kwargs.get('from_condition', "1=1") %}
{% set to_condition = kwargs.get('to_condition', "1=1") %}
{% set severity_level = kwargs.get('severity_level', 'warn') %}
{% set kpi_category = kwargs.get('kpi_category', 'Consistency') %}
{% set p_invocation_id = invocation_id %}
{% set model_text = model | replace("'", "''") %}
{% set field_text = field | replace("'", "''") %}


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

    insert into {{ var('dbt_dq_tool_database', target.database) }}.{{var('dbt_dq_tool_schema', target.schema)}}.dq_issue_log (check_timestamp, table_name, column_name, dq_issue_type, ref_table, ref_column, invocation_id, dq_model, severity, kpi_category, no_of_records, no_of_records_failed)
      (
        with left_table as (

          select
            {{column_name}} as ref_id

          from {{model}}

          where {{column_name}} is not null
            and {{from_condition}}
            {% if where %} and {{ where }} {% endif %}

        ),

        right_table as (

          select
            {{field}} as ref_id

          from {{to}}

          where {{field}} is not null
            and {{to_condition}}

        )

        select
            {{ dq_tools.current_timestamp() }} check_timestamp
          , '{{ model_text }}' table_name
          , '{{ column_name }}' column_name
          , 'reference integrity' dq_issue_type
          , '{{ to }}' ref_table
          , '{{ field_text }}' ref_column

          , '{{ p_invocation_id }}' invocation_id
          , '{{ this }}' dq_model
          , '{{ severity_level }}' severity
          , '{{ kpi_category }}' kpi_category
          , count(*) no_of_records
          , sum(case when right_table.ref_id is null then 1 else 0 end) no_of_records_failed
        from left_table
               left join right_table
                on left_table.ref_id = right_table.ref_id
        group by check_timestamp, table_name, column_name, dq_issue_type, invocation_id, dq_model, severity, kpi_category

      );

    {{ dq_tools.transaction_commit() }}

{% endset %}

{% if var('dbt_test_results_to_db', False) %}

    {% do run_query(sql_cmd) %}
{% endif %}

    with left_table as (

        select
          {{column_name}} as ref_id_left

        from {{model}}

        where {{column_name}} is not null
          and {{from_condition}}
          {% if where %} and {{ where }} {% endif %}

      ),

      right_table as (

        select
          {{field}} as ref_id_right

        from {{to}}

        where {{field}} is not null
          and {{to_condition}}

      )

      select
          *
      from left_table
          left join right_table
          on left_table.ref_id_left = right_table.ref_id_right
      where right_table.ref_id_right is null


{% endtest %}
