--generic
{%- set result_node -%}
test_metadata:
  name: 'test_metadata_name'
  kwargs:
    to: ref('table_a')
    column_name: 'col_1'
    field: 'col_2'
name: test_name
{%- endset %}
select  '{{ dq_tools.__get_to_column_name(fromyaml(result_node)) }}' as actual,
        'col_2' as expected

{%- set result_node -%}
test_metadata:
  name: 'test_metadata_name'
  kwargs:
    column_name: 'col_1'
    # field: 'col_2' # to_column not existing
name: test_name
{%- endset %}
union all
select  '{{ dq_tools.__get_to_column_name(fromyaml(result_node)) }}' as actual,
        '' as expected

--singular
{%- set result_node -%}
name: test_name
{%- endset %}
union all
select  '{{ dq_tools.__get_column_name(fromyaml(result_node)) }}' as actual,
        '' as expected