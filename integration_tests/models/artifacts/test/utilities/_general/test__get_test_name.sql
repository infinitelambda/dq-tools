{%- set result_node -%}
test_metadata:
  name: 'test_metadata_name'
name: test_name
{%- endset %}
select  '{{ dq_tools.__get_test_name(fromyaml(result_node)) }}' as actual,
        'test_metadata_name' as expected

{%- set result_node -%}
name: test_name
{%- endset %}
union all
select  '{{ dq_tools.__get_test_name(fromyaml(result_node)) }}' as actual,
        'test_name' as expected

--error
{%- set result_node -%}
test_metadata_ne:
  name: 'test_metadata_name'
name_ne: test_name
{%- endset %}
union all
select  '{{ dq_tools.__get_test_name(fromyaml(result_node)) }}' as actual,
        '' as expected