{% test equal_rowcount_where_db(model, compare_model) %}

{% set where = kwargs.get('where', kwargs.get('arg')) %}
{% set compare_model_where = kwargs.get('compare_model_where', kwargs.get('arg')) %}
{% set severity_level = kwargs.get('severity_level', 'warn') %}
{% set kpi_category = kwargs.get('kpi_category', 'Consistency') %}
{% set p_invocation_id = invocation_id %}
{% set model_text = model | replace("'", "''") %}
{% set columns_csv = kwargs.get('columns_csv', '*') %}
{% set compare_columns_csv = kwargs.get('compare_columns_csv', kwargs.get('columns_csv', '*')) %}


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

    insert into {{ var('dbt_dq_tool_database', target.database) }}.{{var('dbt_dq_tool_schema', target.schema)}}.dq_issue_log (check_timestamp, table_name, dq_issue_type, ref_table, invocation_id, dq_model, severity, kpi_category, no_of_records, no_of_records_failed)
      (
        with left_table as (

          select
            count({{ columns_csv }}) as count_a

          from {{model}}

          {% if where %} where {{ where }} {% endif %}

        ),

        right_table as (

          select
            count({{ compare_columns_csv }}) as count_b

          from {{ compare_model }}

          {% if compare_model_where %} where {{ compare_model_where }} {% endif %}

        ),

        final as (

            select abs (
                (select count_a from left_table) - (select count_b from right_table)
            ) as diff_count
        )

        select
            {{ dq_tools.current_timestamp() }} check_timestamp
          , '{{ model_text }}' table_name
          , 'equal row count' dq_issue_type
          , '{{ compare_model }}' ref_table

          , '{{ p_invocation_id }}' invocation_id
          , '{{ this }}' dq_model
          , '{{ severity_level }}' severity
          , '{{ kpi_category }}' kpi_category
          , (select count_a from left_table) as no_of_records
          , diff_count as no_of_records_failed
        from final

      );

    {{ dq_tools.transaction_commit() }}

{% endset %}

{% if var('dbt_test_results_to_db', False) %}
   {% do run_query(sql_cmd) %}
{% endif %}

    with left_table as (

        select
          count({{ columns_csv }}) as count_a

        from {{model}}

        {% if where %} where {{ where }} {% endif %}

      ),

      right_table as (

        select
          count({{ compare_columns_csv }}) as count_b

        from {{ compare_model }}

        {% if compare_model_where %} where {{ compare_model_where }} {% endif %}

      ),

      final as (

          select abs (
              (select count_a from left_table) - (select count_b from right_table)
          ) as diff_count
      )

      select
          1
      from final
      where diff_count > 0

{% endtest %}
