--configured in kwargs
{%- set result_node -%}
test_metadata:
  name: 'test_metadata_name'
  kwargs:
    kpi_category: 'kpi_category_1'
config:
  meta:
    kpi_category: 'kpi_category_2'
{%- endset %}
select  '{{ dq_tools.__get_kpi_categorize(fromyaml(result_node)) }}' as actual,
        'kpi_category_1' as expected

--configured in meta
{%- set result_node -%}
test_metadata:
  name: 'test_metadata_name'
  kwargs:
    ne: 'ne'
config:
  meta:
    kpi_category: 'kpi_category_2'
{%- endset %}
union all
select  '{{ dq_tools.__get_kpi_categorize(fromyaml(result_node)) }}' as actual,
        'kpi_category_2' as expected

--not configured, Accuracy based on the test name
{%- set result_node -%}
test_metadata:
  name: 'xyz_accepted_values_xyz'
  kwargs:
    ne: 'ne'
config:
  meta:
    ne: 'ne'
{%- endset %}
union all
select  '{{ dq_tools.__get_kpi_categorize(fromyaml(result_node)) }}' as actual,
        'Accuracy' as expected

--not configured, Consistency based on the test name
{%- set result_node -%}
test_metadata:
  name: 'xyz_equal_rowcount_xyz'
  kwargs:
    ne: 'ne'
config:
  meta:
    ne: 'ne'
{%- endset %}
{% set result_node = fromyaml(result_node) %}
union all
select  '{{ dq_tools.__get_kpi_categorize(result_node) }}' as actual,
        'Consistency' as expected

{%- set result_node -%}
test_metadata:
  name: 'xyz_equality_xyz'
  kwargs:
    ne: 'ne'
config:
  meta:
    ne: 'ne'
{%- endset %}
{% set result_node = fromyaml(result_node) %}
union all
select  '{{ dq_tools.__get_kpi_categorize(result_node) }}' as actual,
        'Consistency' as expected

{%- set result_node -%}
test_metadata:
  name: 'xyz_relationships_xyz'
  kwargs:
    ne: 'ne'
config:
  meta:
    ne: 'ne'
{%- endset %}
{% set result_node = fromyaml(result_node) %}
union all
select  '{{ dq_tools.__get_kpi_categorize(result_node) }}' as actual,
        'Consistency' as expected

--not configured, Completeness based on the test name
{%- set result_node -%}
test_metadata:
  name: 'xyz_not_null_xyz'
  kwargs:
    ne: 'ne'
config:
  meta:
    ne: 'ne'
{%- endset %}
{% set result_node = fromyaml(result_node) %}
union all
select  '{{ dq_tools.__get_kpi_categorize(result_node) }}' as actual,
        'Completeness' as expected

--not configured, Timeliness based on the test name
{%- set result_node -%}
test_metadata:
  name: 'xyz_recency_xyz'
  kwargs:
    ne: 'ne'
config:
  meta:
    ne: 'ne'
{%- endset %}
{% set result_node = fromyaml(result_node) %}
union all
select  '{{ dq_tools.__get_kpi_categorize(result_node) }}' as actual,
        'Timeliness' as expected

--not configured, Validity based on the test name
{%- set result_node -%}
test_metadata:
  name: 'xyz_expression_is_true_xyz'
  kwargs:
    ne: 'ne'
config:
  meta:
    ne: 'ne'
{%- endset %}
{% set result_node = fromyaml(result_node) %}
union all
select  '{{ dq_tools.__get_kpi_categorize(result_node) }}' as actual,
        'Validity' as expected

--not configured, Uniqueness based on the test name
{%- set result_node -%}
test_metadata:
  name: 'xyz_unique_xyz'
  kwargs:
    ne: 'ne'
config:
  meta:
    ne: 'ne'
{%- endset %}
{% set result_node = fromyaml(result_node) %}
union all
select  '{{ dq_tools.__get_kpi_categorize(result_node) }}' as actual,
        'Uniqueness' as expected

--not configured, Other based on the test name
{%- set result_node -%}
test_metadata:
  name: 'xyz_xyz'
  kwargs:
    ne: 'ne'
config:
  meta:
    ne: 'ne'
{%- endset %}
{% set result_node = fromyaml(result_node) %}
union all
select  '{{ dq_tools.__get_kpi_categorize(result_node) }}' as actual,
        'Other' as expected

--singular with not configured
{%- set result_node -%}
name: test_name
config:
  meta:
    ne: 'ne'
{%- endset %}
union all
select  '{{ dq_tools.__get_kpi_categorize(fromyaml(result_node)) }}' as actual,
        'Validity' as expected