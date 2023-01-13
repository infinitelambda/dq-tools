--generic
{%- set result_node -%}
test_metadata:
  name: 'test_metadata_name'
  kwargs:
    column_name: 'col_1'
name: test_name
{%- endset %}
select  '{{ dq_tools.__get_column_name(fromyaml(result_node)) }}' as actual,
        'col_1' as expected

--singular
{%- set result_node -%}
name: test_name
{%- endset %}
union all
select  '{{ dq_tools.__get_column_name(fromyaml(result_node)) }}' as actual,
        '' as expected