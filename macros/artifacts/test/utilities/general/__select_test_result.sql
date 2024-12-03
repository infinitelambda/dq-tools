{% macro __select_test_result(result) -%}

  {%- set dbt_cloud_account_id = env_var("DBT_CLOUD_ACCOUNT_ID", "manual") -%}
  {%- set dbt_cloud_project_id = env_var("DBT_CLOUD_ACCOUNT_ID", "manual") -%}
  {%- set dbt_cloud_job_id = env_var("DBT_CLOUD_ACCOUNT_ID", "manual") -%}
  {%- set dbt_cloud_run_id = env_var("DBT_CLOUD_ACCOUNT_ID", "manual") -%}

  {%- set test_type = dq_tools.__get_test_type(result.node) -%}
  {%- set testing_model = dq_tools.__get_test_model(result.node) -%}
  {%- set testing_model_relation = dq_tools.__get_relation(testing_model) -%}
  {%- set materialization = dq_tools.__get_test_model_materialization(testing_model.name) -%}
  {%- set test_description = dq_tools.__get_test_description(result.node) -%}

  /* {{ testing_model }} */

  select   '{{ result.node.unique_id }}' as test_unique_id
          ,'{{ result.node.alias }}' as test_name
          ,'{{ result.node.name }}' as test_name_long
          ,'{{ result.node.database ~ "." ~ result.node.schema ~ "." ~ result.node.name }}' as dq_model
          ,'{{ result.node.config.severity | lower }}' as test_severity_config
          ,'{{ dq_tools.__get_kpi_categorize(result.node) }}' as test_kpi_category_config
          ,'{{ dq_tools.__get_dq_issue_type(result.node) }}' as dq_issue_type
          ,'{{ result.status }}' as test_result
          ,{% if materialization != 'ephemeral' %}
            '{{ testing_model_relation }}'
            {% else %}''{% endif %} as table_name
          ,'{{ dq_tools.__get_where_subquery(
                testing_model,
                result.node.config,
                sql_escape=true) }}' as table_query
          ,'{{ dq_tools.__get_to_relation(result.node) }}' as ref_table
          ,'{{ dq_tools.__get_column_name(result.node) | escape }}' as column_name
          ,{% if test_type == 'generic' and materialization != 'ephemeral' %}
              {{ adapter.get_columns_in_relation(testing_model_relation) | length }}
            {% else %}null{% endif %} as no_of_table_columns
          ,'{{ dq_tools.__get_to_column_name(result.node) | escape }}' as ref_column
          ,{% if test_type == 'generic' and materialization != 'ephemeral' %}(
              select  count(*)
              from    {{ testing_model_relation }}
            ){% else %}null{% endif %} as no_of_records
          ,{% if test_type == 'generic' and materialization != 'ephemeral' %}(
              select  count(*)
              from    {{ dq_tools.__get_where_subquery(testing_model, result.node.config) }}
            ){% else %}null{% endif %} as no_of_records_scanned
          ,coalesce({{ result.failures or 'null' }}, 0) as no_of_records_failed
          ,'{{ test_type }}' as test_type
          ,'{{ test_description }}' as test_description
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
          ,{{ dq_tools.current_timestamp_in_utc() }} as _timestamp

{%- endmacro %}