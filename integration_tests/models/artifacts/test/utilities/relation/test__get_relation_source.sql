-- depends_on: {{ source('artifacts_seed', 'data_test__relation') }}
select  '{{ dq_tools.__get_relation_source("artifacts_seed", "data_test__relation") }}' as actual,
        '{{ source("artifacts_seed", "data_test__relation") }}' as expected