{% macro __select_test_result(result) -%}

  {%- set dbt_cloud_account_id = env_var("DBT_CLOUD_ACCOUNT_ID", "manual") -%}
  {%- set dbt_cloud_project_id = env_var("DBT_CLOUD_ACCOUNT_ID", "manual") -%}
  {%- set dbt_cloud_job_id = env_var("DBT_CLOUD_ACCOUNT_ID", "manual") -%}
  {%- set dbt_cloud_run_id = env_var("DBT_CLOUD_ACCOUNT_ID", "manual") -%}

  select   '{{ result.node.alias }}' as test_name
          ,'{{ result.node.name }}' as test_name_long
          ,'{{ result.node.database ~ "." ~ result.node.schema ~ "." ~ result.node.name }}' as dq_model
          ,'{{ result.node.config.severity | lower }}' as test_severity_config
          ,'{{ dq_tools.__get_kpi_categorize(result.node) }}' as test_kpi_category_config
          ,'{{ dq_tools.__get_dq_issue_type(result.node) }}' as dq_issue_type
          ,'{{ result.status }}' as test_result
          /* - for debugging purpose -
            __get_test_model:
            {{ dq_tools.__get_test_model(result.node) -}}
          */
          ,'{{ dq_tools.__get_where_subquery(
                dq_tools.__get_test_model(result.node),
                result.node.config,
                sql_escape=true) }}' as table_name
          ,'{{ dq_tools.__get_to_relation(result.node) }}' as ref_table
          ,'{{ dq_tools.__get_column_name(result.node) | escape }}' as column_name
          ,'{{ dq_tools.__get_to_column_name(result.node) | escape }}' as ref_column
          ,{% if dq_tools.__get_test_type(result.node) == 'generic' %}(
            select  count(*)
            from    {{ dq_tools.__get_where_subquery(
                        dq_tools.__get_test_model(result.node),
                        result.node.config
                      )
                    }}
          ){% else %}null
          {%- endif %} as no_of_records
          ,coalesce({{ result.failures or 'null' }}, 0) as no_of_records_failed
          ,'{{ dq_tools.__get_test_type(result.node) }}' as test_type
          ,'{{ result.execution_time }}' as execution_time_seconds
          ,'{{ result.node.original_file_path }}' as file_test_defined
          ,'{{ target.name }}' as dbt_target_name
          ,'{{ invocation_id }}' as dbt_invocation_id
          ,'{{ dbt_cloud_account_id }}' as _audit_account_id
          ,'{{ dbt_cloud_project_id }}' as _audit_project_id
          ,'{{ dbt_cloud_job_id }}' as _audit_job_id
          ,'{{ dbt_cloud_run_id }}' as _audit_run_id
          ,concat(
            '{{ env_var("DBT_CLOUD_URL", "https://cloud.getdbt.com/#/accounts/") ~ dbt_cloud_account_id }}',
            '/projects/{{ dbt_cloud_account_id }}',
            '/runs/{{ dbt_cloud_run_id }} '
          ) as audit_run_url
          ,{{ dq_tools.current_timestamp() }} as _timestamp

{%- endmacro %}