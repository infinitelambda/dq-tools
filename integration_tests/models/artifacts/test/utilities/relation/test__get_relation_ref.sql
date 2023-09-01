-- depends_on: {{ ref('data_test__relation') }}
select  '{{ dq_tools.__get_relation_ref("data_test__relation") }}' as actual,
        '{{ adapter.get_relation(database=target.database, schema=generate_schema_name("seed"), identifier="data_test__relation") }}' as expected

-- depends_on: {{ ref('model_test__relation') }}
union all
select  '{{ dq_tools.__get_relation_ref("model_test__relation") }}' as actual,
        '{{ adapter.get_relation(database=target.database, schema=target.schema, identifier="model_test__relation") }}' as expected