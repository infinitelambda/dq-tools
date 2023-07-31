{% test equality_where_db(model, compare_model) %}

{% set compare_columns = kwargs.get('compare_columns', None) %}
{% set where = kwargs.get('where', kwargs.get('arg')) %}
{% set compare_model_where = kwargs.get('compare_model_where', kwargs.get('arg')) %}
{% set severity_level = kwargs.get('severity_level', 'warn') %}
{% set kpi_category = kwargs.get('kpi_category', 'Consistency') %}
{% set p_invocation_id = invocation_id %}
{% set model_text = model | replace("'", "''") %}


{% if kpi_category not in ['Accuracy', 'Consistency', 'Completeness', 'Timeliness', 'Validity', 'Uniqueness'] %}
    {% set kpi_category = 'Other'%}
{% endif %}


{%- if not compare_columns -%}
    {%- set compare_columns = adapter.get_columns_in_relation(model) | map(attribute='quoted') -%}
{%- endif -%}

{% set compare_cols_csv = compare_columns | join(', ') %}


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
            *
          from {{model}}

          {% if where %} where {{ where }} {% endif %}

        ),

        right_table as (

          select
            *
          from {{ compare_model }}

          {% if compare_model_where %} where {{ compare_model_where }} {% endif %}

        ),

        left_minus_right as (

            select {{ compare_cols_csv }} from left_table
            {{ dq_tools.except() }}
            select {{ compare_cols_csv }} from right_table

        ),

        right_minus_left as (

            select {{ compare_cols_csv }} from right_table
            {{ dq_tools.except() }}
            select {{ compare_cols_csv }} from left_table

        ),

        unionized as (
            select * from left_minus_right
            union all
            select * from right_minus_left
        )

        select
            {{ dq_tools.current_timestamp() }} check_timestamp
          , '{{ model_text }}' table_name
          , 'equality' dq_issue_type
          , '{{ compare_model }}' ref_table

          , '{{ p_invocation_id }}' invocation_id
          , '{{ this }}' dq_model
          , '{{ severity_level }}' severity
          , '{{ kpi_category }}' kpi_category
          , (select count(*) from left_table) as no_of_records
          , (select count(*) from unionized) as no_of_records_failed
      );

    {{ dq_tools.transaction_commit() }}

{% endset %}

{% if var('dbt_test_results_to_db', False) %}
   {% do run_query(sql_cmd) %}
{% endif %}

    with left_table as (

          select
            *
          from {{model}}

          {% if where %} where {{ where }} {% endif %}

        ),

        right_table as (

          select
            *
          from {{ compare_model }}

          {% if compare_model_where %} where {{ compare_model_where }} {% endif %}

        ),

        left_minus_right as (

            select {{ compare_cols_csv }} from left_table
            {{ dq_tools.except() }}
            select {{ compare_cols_csv }} from right_table

        ),

        right_minus_left as (

            select {{ compare_cols_csv }} from right_table
            {{ dq_tools.except() }}
            select {{ compare_cols_csv }} from left_table

        ),

        unionized as (
            select * from left_minus_right
            union all
            select * from right_minus_left
        )

        select *
        from unionized

{% endtest %}
