{% test unique_where_db(model) %}

{% set column_name = kwargs.get('column_name', kwargs.get('arg')) %}
{% set where = kwargs.get('where', kwargs.get('arg')) %}
{% set severity_level = kwargs.get('severity_level', 'warn') %}
{% set kpi_category = kwargs.get('kpi_category', 'Uniqueness') %}
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

        with duplications as (
            select
                row_number() over (partition by {{ column_name }} order by 1) duplicated_value
            from {{ model }}
            {% if where %} where {{ where }} {% endif %}
        )

        select
            {{ dq_tools.current_timestamp() }} check_timestamp
          , '{{ model_text }}' table_name
          , '{{ column_name }}' column_name
          , 'uniqueness' dq_issue_type

          , '{{ p_invocation_id }}' invocation_id
          , '{{ this }}' dq_model
          , '{{ severity_level }}' severity
          , '{{ kpi_category }}' kpi_category
          , count(*) no_of_records
          , sum(case when duplicated_value>1 then 1 else 0 end) no_of_records_failed
        from duplications

      );

    {{ dq_tools.transaction_commit() }}

{% endset %}


{% if var('dbt_test_results_to_db', False) %}
    {% do run_query(sql_cmd) %}
{% endif %}

    with duplications as (
        select
            row_number() over (partition by {{ column_name }} order by 1) duplicated_value
        from {{ model }}
        {% if where %} where {{ where }} {% endif %}
    )

    select
        *
    from duplications
    where duplicated_value > 1

{% endtest %}
