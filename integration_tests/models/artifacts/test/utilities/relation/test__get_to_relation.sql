-- 'to' to seed
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    to: "ref('data_test__relation')"
{%- endset %}
select  '{{  dq_tools.__get_to_relation(fromyaml(result_node)) | replace("`","") }}' as actual,
        '{{ target.database }}.{{ generate_schema_name("seed") }}.data_test__relation' as expected

-- 'to' to model
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    to: "ref('model_test__relation')"
{%- endset %}
union all
select  '{{  dq_tools.__get_to_relation(fromyaml(result_node)) | replace("`","") }}' as actual,
        '{{ target.database }}.{{ target.schema }}.model_test__relation' as expected

-- 'to' to source
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    to: "source('artifacts_seed', 'data_test__relation')"
{%- endset %}
union all
select  '{{  dq_tools.__get_to_relation(fromyaml(result_node)) | replace("`","") }}' as actual,
        '{{ target.database }}.dq_tools_integration_tests_seed.data_test__relation' as expected