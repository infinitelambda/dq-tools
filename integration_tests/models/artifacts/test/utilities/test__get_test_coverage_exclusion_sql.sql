select  'integration test - default' as test_case,
        '{{ dq_tools.__get_test_coverage_exclusion_sql() | replace(" ", "") | replace("\n", "") | escape }}' as actual,
        '{{(
          "((lower(split(table_name,'.')[0])in('dummy'))or(lower(split(table_name,'.')[1])in('"
          ~ generate_schema_name("dq_tools_mart")
          ~ "'))or(lower(split(table_name,'.')[2])in('dq_issue_log','dummy')))"
        ) | escape | lower }}' as expected