-- depends_on: {{ source('artifacts_seed', 'data_test__relation') }}
select  '{{ dq_tools.__get_relation_source("artifacts_seed", "data_test__relation") | replace("`","") }}' as actual,
        '{{ target.database }}.dq_tools_integration_tests_seed.data_test__relation' as expected