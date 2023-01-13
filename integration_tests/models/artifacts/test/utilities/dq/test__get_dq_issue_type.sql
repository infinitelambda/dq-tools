--configured in kwargs
{%- set result_node -%}
test_metadata:
  name: 'test_metadata_name'
  kwargs:
    dq_issue_type: 'issue_type_1'
config:
  meta:
    dq_issue_type: 'issue_type_2'
{%- endset %}
select  '{{ dq_tools.__get_dq_issue_type(fromyaml(result_node)) }}' as actual,
        'issue_type_1' as expected

--configured in meta
{%- set result_node -%}
test_metadata:
  name: 'test_metadata_name'
  kwargs:
    ne: 'ne'
config:
  meta:
    dq_issue_type: 'issue_type_2'
{%- endset %}
union all
select  '{{ dq_tools.__get_dq_issue_type(fromyaml(result_node)) }}' as actual,
        'issue_type_2' as expected

--not configured, take test name
{%- set result_node -%}
test_metadata:
  name: 'test_metadata_name'
  kwargs:
    ne: 'ne'
config:
  meta:
    ne: 'ne'
{%- endset %}
union all
select  '{{ dq_tools.__get_dq_issue_type(fromyaml(result_node)) }}' as actual,
        'test metadata name' as expected

--singular
{%- set result_node -%}
name: test_name
config:
  meta:
    ne: 'ne'
{%- endset %}
union all
select  '{{ dq_tools.__get_dq_issue_type(fromyaml(result_node)) }}' as actual,
        'business test' as expected