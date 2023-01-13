{% macro create_dq_issue_log() -%}

{%- if var('dbt_dq_tool_schema', '') == '' %}
  {{ exceptions.raise_compiler_error(
      'Cannot create the table DQ_ISSUE_LOG: Please add the missing variable `dbt_dq_tool_schema`'
    )
  }}
{% endif -%}

{%- if target.type | lower == 'snowflake'  %}
  {%- set query %}
    create schema if not exists {{ target.database }}.{{ var('dbt_dq_tool_schema') }};
    create transient table if not exists {{ target.database }}.{{ var('dbt_dq_tool_schema') }}.dq_issue_log
    (
      CHECK_TIMESTAMP TIMESTAMP_NTZ(9),
      TABLE_NAME VARCHAR(16777216),
      COLUMN_NAME VARCHAR(16777216),
      COLUMN_VALUE VARCHAR(16777216),
      REF_TABLE VARCHAR(16777216),
      REF_COLUMN VARCHAR(16777216),
      DQ_ISSUE_TYPE VARCHAR(16777216),
      INVOCATION_ID VARCHAR(16777216),
      DQ_MODEL VARCHAR(16777216),
      SEVERITY VARCHAR(16777216),
      KPI_CATEGORY VARCHAR(16777216),
      NO_OF_RECORDS NUMBER(38,0),
      NO_OF_RECORDS_FAILED NUMBER(38,0),
      constraint PK_DQ_ISSUE_LOG primary key (DQ_MODEL, INVOCATION_ID)
    );
  {% endset -%}

{%- elif target.type | lower == 'bigquery' %}
  {%- set query %}
    create table if not exists {{ target.project }}.{{ var('dbt_dq_tool_schema') }}.dq_issue_log
    (
      CHECK_TIMESTAMP TIMESTAMP,
      TABLE_NAME STRING,
      COLUMN_NAME STRING,
      COLUMN_VALUE STRING,
      REF_TABLE STRING,
      REF_COLUMN STRING,
      DQ_ISSUE_TYPE STRING,
      INVOCATION_ID STRING,
      DQ_MODEL STRING,
      SEVERITY STRING,
      KPI_CATEGORY STRING,
      NO_OF_RECORDS NUMERIC,
      NO_OF_RECORDS_FAILED NUMERIC
    );
  {% endset -%}

{% endif -%}


{%- if execute and flags.WHICH in ['run-operation'] %}

  {% do run_query(query) %}
  {{ log("Done: create_table_dq_issue_log", info=True) }}

{%- elif execute
  and flags.WHICH in ['build','run','test','compile'] %}

  {{- query -}}

{% endif -%}

{%- endmacro %}