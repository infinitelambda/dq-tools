{%- set result_node -%}
test_metadata:
  name: 'test_metadata_name'
name: test_name
{%- endset %}
select  '{{ dq_tools.__get_test_type(fromyaml(result_node)) }}' as actual,
        'generic' as expected

{%- set result_node -%}
name: test_name
{%- endset %}
union all
select  '{{ dq_tools.__get_test_type(fromyaml(result_node)) }}' as actual,
        'singular' as expected

--error
{%- set result_node -%}
test_metadata_ne:
  name: 'test_metadata_name'
name_ne: test_name
{%- endset %}
union all
select  '{{ dq_tools.__get_test_type(fromyaml(result_node)) }}' as actual,
        '' as expected