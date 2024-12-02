-- test not_null
{% set result_node = {
    "test_metadata": {
        "name": "not_null",
        "kwargs": {
            "column_name": "indicator_category",
            "model": "{{ get_where_subquery(ref('bi_column_analysis')) }}"
        },
    } 
} %}

select '{{ dq_tools.__get_test_description(result_node) }}' as actual,
       'The indicator_category column in the bi_column_analysis model should not contain null values.' as expected

-- test unique
{% set result_node = {
    "test_metadata": {
        "name": "unique",
        "kwargs": {
            "column_name": "invocation_id",
            "model": "{{ get_where_subquery(ref('test_coverage')) }}"
        }
    }
} %}

union all
select '{{ dq_tools.__get_test_description(result_node) }}' as actual,
       'The invocation_id column in the test_coverage model should be unique.' as expected

-- test relationships
{% set result_node = {

    "test_metadata": {
                "name": "relationships",
                "kwargs": {
                    "to": "ref('data_test_relationships_a')",
                    "field": "a_id",
                    "column_name": "b_id",
                    "model": "{{ get_where_subquery(ref('data_test_relationships_b')) }}"
                }
    }
} %}

union all
select '{{ dq_tools.__get_test_description((result_node)) }}' as actual,
       'Each b_id in the data_test_relationships_b model exists as an id in the data_test_relationships_a table.' as expected

-- test no test description
{% set result_node = {
    "test_metadata": {
        "name": "not_null_where_db",
        "kwargs": {
            "column_name": "check_timestamp",
            "model": "{{ get_where_subquery(ref('dq_tools_test')) }}"
        }
    }
} %}

union all
select '{{ dq_tools.__get_test_description(result_node) }}' as actual,
       '' as expected

{% set result_node = {
    "test_metadata": {
                "name": "accepted_values",
                "kwargs": {
                    "values": [
                        "Simple Statistics"
                    ],
                    "column_name": "indicator_category",
                    "model": "{{ get_where_subquery(ref('bi_dq_metrics')) }}"
                },
                "namespace": null
            },
    "description": "The indicator_category column should only contain simple statistics value"
} %}

union all
select 
    '{{ dq_tools.__get_test_description(result_node) }}' as actual,
    'The indicator_category column should only contain simple statistics value' as expected