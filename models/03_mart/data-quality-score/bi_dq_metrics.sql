{{
  config(
    tags = ['dq']
  )
}}

with dq_metrics_only as (

  select  run_time,
          analysis_name as rule_name,
          table_name as data_concept,
          column_name as data_element,
          indicator_category,
          case
            when coalesce(kpi_category,'') != '' then kpi_category
            when lower(analysis_name) like '%expression%'        then 'Validity'
            when lower(analysis_name) like '%recency%'           then 'Timeliness'
            when lower(analysis_name) like '%accuracy%'
              or lower(analysis_name) like '%accepted values%'   then 'Accuracy'
            when lower(analysis_name) like '%uniqueness%'
              or lower(analysis_name) like '%unique%'            then 'Uniqueness'
            when lower(analysis_name) like '%null value%'
              or lower(analysis_name) like '%not null%'          then 'Completeness'
            when lower(analysis_name) like '%reference integrity%'
              or lower(analysis_name) like '%relationships%'     then 'Consistency'
            else 'Other'
          end as dq_dimension,
          rows_processed,
          case
            when indicator_category in ('Simple Statistics') then indicator_value
            when indicator_category in ('Pattern Matching') then rows_processed - indicator_value
            else indicator_value
          end as rows_failed

  from    {{ ref('bi_column_analysis') }}

)

select  *, rows_processed - rows_failed as rows_passed
from    dq_metrics_only