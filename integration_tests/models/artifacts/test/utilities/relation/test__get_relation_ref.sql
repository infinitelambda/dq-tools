-- depends_on: {{ ref('data_test__relation') }}
select  '{{ dq_tools.__get_relation_ref("data_test__relation") }}' as actual,
        '{{ target.database }}.{{ target.schema }}_seed.data_test__relation' as expected

-- depends_on: {{ ref('model_test__relation') }}
union all
select  '{{ dq_tools.__get_relation_ref("model_test__relation") }}' as actual,
        '{{ target.database }}.{{ target.schema }}.model_test__relation' as expected