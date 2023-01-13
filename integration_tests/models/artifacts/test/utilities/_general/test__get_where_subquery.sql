-- depends_on: {{ ref('data_test__get_where_subquery') }}
-- ref without where
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(ref('data_test__get_where_subquery')) ]]"
config:
  where_ne: ''
{%- endset -%}
{%- set result_node = fromyaml(result_node.replace("]","}").replace("[","{")) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
select  'ref without where' as test_case,
        '{{ result_node | escape }}' as input,
        '{{  dq_tools.__get_where_subquery(test_model, result_node.config) }}' as actual,
        '{{ target.database }}.{{ generate_schema_name("seed") }}.data_test__get_where_subquery' as expected

-- ref with where
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(ref('data_test__get_where_subquery')) ]]"
config:
  where: 'id = 1'
{%- endset -%}
{%- set result_node = fromyaml(result_node.replace("]","}").replace("[","{")) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
union all
select  'ref with where' as test_case,
        '{{ result_node | escape }}' as input,
        '{{  dq_tools.__get_where_subquery(test_model, result_node.config) }}' as actual,
        '(select * from {{ target.database }}.{{ generate_schema_name("seed") }}.data_test__get_where_subquery where id = 1) dbt_subquery' as expected

-- ref with where | escape
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(ref('data_test__get_where_subquery')) ]]"
config:
  where: id = '1'
{%- endset -%}
{%- set result_node = fromyaml(result_node.replace("]","}").replace("[","{")) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
union all
select  'ref with where | sql_escape' as test_case,
        '{{ result_node | escape }}' as input,
        '{{  dq_tools.__get_where_subquery(test_model, result_node.config, sql_escape=true) }}' as actual,
        '(select * from {{ target.database }}.{{ generate_schema_name("seed") }}.data_test__get_where_subquery where id = \'1\') dbt_subquery' as expected

-- ref referencing a package
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(ref('package_a', 'data_test__get_where_subquery')) ]]"
config:
  where: 'id = 1'
{%- endset -%}
{%- set result_node = fromyaml(result_node.replace("]","}").replace("[","{")) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
union all
select  'ref referencing a package' as test_case,
        '{{ result_node | escape }}' as input,
        '{{  dq_tools.__get_where_subquery(test_model, result_node.config) }}' as actual,
        '(select * from {{ target.database }}.{{ generate_schema_name("seed") }}.data_test__get_where_subquery where id = 1) dbt_subquery' as expected

-- ref error
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(ref('this is not existing model')) ]]"
config:
  where: 'id = 1'
{%- endset -%}
{%- set result_node = fromyaml(result_node.replace("]","}").replace("[","{")) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
union all
select  'ref error' as test_case,
        '{{ result_node | escape }}' as input,
        '{{  dq_tools.__get_where_subquery(test_model, result_node.config) }}' as actual,
        '' as expected

-- source without where
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(source('artifacts_seed', 'data_test__get_where_subquery')) ]]"
config:
  where_ne: ''
{%- endset -%}
{%- set result_node = fromyaml(result_node.replace("]","}").replace("[","{")) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
union all
select  'source without where' as test_case,
        '{{ result_node | escape }}' as input,
        '{{  dq_tools.__get_where_subquery(test_model, result_node.config) | replace("`","") }}' as actual,
        '{{ target.database }}.dq_tools_integration_tests_seed.data_test__get_where_subquery' as expected

-- source with where
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(source('artifacts_seed', 'data_test__get_where_subquery')) ]]"
config:
  where: 'id = 1'
{%- endset -%}
{%- set result_node = fromyaml(result_node.replace("]","}").replace("[","{")) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
union all
select  'source with where' as test_case,
        '{{ result_node | escape }}' as input,
        '{{  dq_tools.__get_where_subquery(test_model, result_node.config) | replace("`","") }}' as actual,
        '(select * from {{ target.database }}.dq_tools_integration_tests_seed.data_test__get_where_subquery where id = 1) dbt_subquery' as expected

-- source error
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(source('xxx', 'this is not existing model')) ]]"
config:
  where_ne: 'id = 1'
{%- endset -%}
{%- set result_node = fromyaml(result_node.replace("]","}").replace("[","{")) %}
{%- set test_model = dq_tools.__get_test_model(result_node) %}
union all
select  'source error' as test_case,
        '{{ result_node | escape }}' as input,
        '{{  dq_tools.__get_where_subquery(test_model, result_node.config) }}' as actual,
        '' as expected
