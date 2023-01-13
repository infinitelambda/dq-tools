--ref('table')
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(ref('table')) ]]"
{%- endset -%}
{%- set result_node = result_node.replace("]","}").replace("[","{") %}
select  '{{ dq_tools.__get_test_model(fromyaml(result_node)) | escape }}' as actual,
        '{{ {'type': 'ref', 'name': 'table', 'package_name': ''} | escape }}' as expected

--ref('package_a', 'table')
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(ref('package_a', 'table')) ]]"
{%- endset -%}
{%- set result_node = result_node.replace("]","}").replace("[","{") %}
union all
select  '{{ dq_tools.__get_test_model(fromyaml(result_node)) | escape }}' as actual,
        '{{ {'type': 'ref', 'name': 'table', 'package_name': 'package_a'} | escape }}' as expected

--source('source_a', 'table')
{%- set result_node -%}
test_metadata:
  name: 'test_name'
  kwargs:
    model: "[[ get_where_subquery(source('source_a', 'table')) ]]"
{%- endset -%}
{%- set result_node = result_node.replace("]","}").replace("[","{") %}
union all
select  '{{ dq_tools.__get_test_model(fromyaml(result_node)) | escape }}' as actual,
        '{{ {'type': 'source', 'name': 'table', 'source_name': 'source_a'} | escape }}' as expected

--error
{%- set result_node -%}
test_not_exist_metadata:
  name: 'test_name'
{%- endset %}
union all
select  '{{ dq_tools.__get_test_model(fromyaml(result_node)) }}' as actual,
        'None' as expected