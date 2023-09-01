select  'integration test - default' as test_case,
        '{{ var("dbt_dq_tool_test_coverage_exclusion", {}) | escape }}' as test_input,
        '{{ dq_tools.__get_test_coverage_exclusion() | escape }}' as actual,
        '{{ ("{'databases': ['dummy'], 'schemas': ['" | escape) 
            ~ generate_schema_name("dq_tools_mart") 
            ~ ("'], 'tables': ['dq_issue_log', 'dummy']}" | escape) }}' as expected

{%- set test_input -%}
{%- endset %}
{%- set rule = (fromyaml(test_input) or {}).get('dbt_dq_tool_test_coverage_exclusion', {}) %}
union all
select  'integration test - default' as test_case,
        '{{ rule | escape }}' as test_input,
        '{{ dq_tools.__get_test_coverage_exclusion(rule=rule) | escape }}' as actual,
        '{{ "{'databases': [], 'schemas': [], 'tables': []}" | escape }}' as expected

{%- set test_input -%}
dbt_dq_tool_test_coverage_exclusion:
  by_database: ['dummy', 'dummy2']
  by_schema: ['dummy1', 'dummy2', 'dummy3']
  by_table: ['dummy1', 'dummy2']
{%- endset %}
{%- set rule = (fromyaml(test_input) or {}).get('dbt_dq_tool_test_coverage_exclusion', {}) %}
union all
select  'multiple values accros all arguments' as test_case,
        '{{ rule | escape }}' as test_input,
        '{{ dq_tools.__get_test_coverage_exclusion(rule=rule) | escape }}' as actual,
        '{{ ("{'databases': ['dummy', 'dummy2'], 'schemas': ["
          ~ "'" ~ generate_schema_name("dummy1") ~ "', "
          ~ "'" ~ generate_schema_name("dummy2") ~ "', "
          ~ "'" ~ generate_schema_name("dummy3") ~ "'"
          ~ "], 'tables': ['dummy1', 'dummy2']}") | escape }}' as expected