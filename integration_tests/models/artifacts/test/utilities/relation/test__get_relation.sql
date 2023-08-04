-- ref to seed
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(ref('data_test__relation')) ]]"
{%- endset -%}
{%- set result_node = fromyaml(result_node.replace("]","}").replace("[","{")) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
select  '{{  dq_tools.__get_relation(test_model) }}' as actual,
        '{{ adapter.get_relation(database=target.database, schema=generate_schema_name("seed"), identifier="data_test__relation") }}' as expected

-- ref to model
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(ref('model_test__relation')) ]]"
{%- endset -%}
{%- set result_node = fromyaml(result_node.replace("]","}").replace("[","{")) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
union all
select  '{{  dq_tools.__get_relation(test_model) }}' as actual,
        '{{ adapter.get_relation(database=target.database, schema=target.schema, identifier="model_test__relation") }}' as expected

-- source to seed
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(source('artifacts_seed', 'data_test__relation')) ]]"
{%- endset -%}
{%- set result_node = fromyaml(result_node.replace("]","}").replace("[","{")) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
union all
select  '{{  dq_tools.__get_relation(test_model) }}' as actual,
        '{{ source("artifacts_seed", "data_test__relation") }}' as expected

-- error
{%- set result_node -%}
name: test_name
{%- endset -%}
{%- set result_node = fromyaml(result_node) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
union all
select  '{{  dq_tools.__get_relation(test_model) }}' as actual,
        '' as expected