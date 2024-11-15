# Data Quality Tools

<img align="right" width="150" height="150" src="https://raw.githubusercontent.com/infinitelambda/dq-tools/main/docs/assets/img/il-logo.png">

The purpose of the dq tool is to make simple storing test results and visualisation of these in a BI dashboard.

[![dq-tools](https://img.shields.io/badge/official--documentation--site-visit-blueviolet)](https://infinitelambda.github.io/dq-tools/)

[![dbt-hub](https://img.shields.io/badge/dbt-hub-FF694B?logo=dbt&logoColor=FF694B)](https://hub.getdbt.com/infinitelambda/dq_tools)
[![ci-pr](https://github.com/infinitelambda/dq-tools/actions/workflows/ci-pr.yml/badge.svg)](https://github.com/infinitelambda/dq-tools/actions/workflows/ci-pr.yml)

**Supported DWHs**:

![dwh](https://img.shields.io/badge/DWH-Snowflake-9cf?logo=snowflake&logoColor=white)
![dwh](https://img.shields.io/badge/DWH-BigQuery-green?logo=google&logoColor=white)

**Installation**:

- Add to `packages.yml` file:

  ```yml
  packages:
    - package: infinitelambda/dq_tools
      version: [">=1.8.0", "<1.9.0"]
  ```

- (Optional) Configure schema in `dbt_project.yml` file:

  ```yml
  models:
    dq_tools:
      # +database: DQ
      +schema: AUDIT
      
  vars: # (TO BE DEPRECATED, currently used only in test macros)
    # dbt_dq_tool_database: DQ
    dbt_dq_tool_schema: AUDIT
  ```

- Add on-run-end hook:

  ```yml
  on-run-end:
    - '{{ dq_tools.store_test_results(results) }}'
  ```

- Initialize `dq-tools` (new in v1.4+)

  ```bash
  dbt run -s dq_tools 
  ```

 - Then, decide to save the test result in dbt command:

   ```bash
   dbt test --vars '{dq_tools_enable_store_test_results: True}'
   dbt build --vars '{dq_tools_enable_store_test_results: True}'
   ```
 
   Alternatively, we can also enable this variable in <code>dbt_project.yml`</code>:
   ```yml
   vars:
     # to store the test results in db table
     dq_tools_enable_store_test_results: True
   ```

See [Installation Instructions](#installation-instructions) in more details.

## 3 Functional layers

- store dbt test results in a table
- create mart for DQ test result
- provide BI dashboard for visualisation

The idea behind the layer is that each layer can be changed, extended or replaced without or with minimal impact on the other 2.

## Data Quality KPIs

There are 6 main KPIs will be produced as below:

- Accuracy
- Consistency
- Completeness
- Timeliness
- Validity
- Uniqueness

![DataQualityKPIs](https://raw.githubusercontent.com/infinitelambda/dq-tools/main/assets/images/DataQualityKPIs.png)

NOTE: It is possible that we can have custom KPI(s) as you go but it is NOT recommended as the existing modelling design will stick to the above 6 ones only.

```yaml
models:
  - name: my_model
    columns:
      - name: my_column
        data_tests:
          - dq_tools.unique_where_db:
              kpi_category: MyKPI # not recommended
```

## Quick Demo

- STEP 1 - Installation:
  - install dq tools package
  - create dq log issue table following the documentation in the package.
  - create metrics views
  - set up looker dashboard

- STEP 2 - define dbt data_tests:
  Define tests following the description in the package documentation.

  ```yaml
  models:
  - name: dim_customers
    description: This table has basic information about a customer, as well as some derived facts based on a customer's orders
    data_tests:
      - dq_tools.equal_rowcount_where_db:
          compare_model: ref('stg_customers')
          where: customer_id > 50
          compare_model_where: customer_id > 50
    columns:
      - name: customer_id
        description: This is a unique identifier for a customer
        data_tests:
          - dq_tools.unique_where_db
          - dq_tools.not_null_where_db
  ```

- STEP 3 - run the dbt test and check:
  Test results in the dq issue log table:
  ![TestResultLog](https://raw.githubusercontent.com/infinitelambda/dq-tools/main/assets/images/TestResultLog.png)

  Data quality KPIs in looker:
  ![LookerDashboard](https://raw.githubusercontent.com/infinitelambda/dq-tools/main/assets/images/LookerDashboard.png)

## Installation Instructions

Go to [dbt Hub](https://hub.getdbt.com/infinitelambda/dq_tools/latest/) and register the package into your dbt `packages.yml` file:

  ```yml
  packages:
    - package: infinitelambda/dq_tools
      version: [">=1.2.0", "<1.3.0"]
  ```

### 1. Create table DQ_ISSUE_LOG in the database

Since the version 1.3, the table `dq_issue_log` is made as dbt model, no more manual hook config :tada:.

It should be created automatically within your upstream dbt command. If not, all you should do that is running the command: `dbt run -s dq_tools`.

> [!NOTE]
> If you already have a `metricflow_time_spine` model in your project, you will encounter a Compilation error when executing `dbt run -s dq_tools`. In this scenario, disable the `metricflow_time_spine` model by updating its configuration in your project (path: your_project/dbt_packages/dq_tools/models/04_metric/metricflow_time_spine).


<details>
  <summary>For dq-tools legacy version >=1.0,<1.3</summary>

  A macro `create_table_dq_issue_log` ([source](https://github.com/infinitelambda/dq-tools/blob/main/macros/create_table_dq_issue_log.sql)) will create the log table in your database (Snowflake) / project (BigQuery).

  Add `on-run-start` hook (required dbt >= 1.0.0):

  ```yml
  on-run-start:
    - '{{ dq_tools.create_table_dq_issue_log() }}'
  ```

</details>

<details>
  <summary>For dq-tools legacy version < 1.0, you can run it as an operation</summary>

  ```bash
  dbt run-operation create_dq_issue_log
  ```

</details>

### 2. Configure your DQ schema with `dbt_dq_tool_schema` variable:

Value for variable `dbt_dq_tool_schema: your_schema_name` needs to be added to dbt_project.yml file in your project. And then, optionally add `dbt_dq_tool_database: your_database_name` which default value is `target.schema` in `profiles.yml` file

e.g.

```yaml
vars:
  # (optional) to create db table in the schema named as AUDIT, default to `target.schema`
  dbt_dq_tool_schema: AUDIT
  # (optional) to create db table in the database named as DQ_TOOLS, default to `target.database`
  dbt_dq_tool_database: DQ_TOOLS
```

### 3. Decide to save test result to Data Warehouse table:

#### With `dq_tools_enable_store_test_results` variable:

Add the `on-run-end` hook to you project:

```yaml
on-run-end:
  - '{{ dq_tools.store_test_results(results) }}'
```

Then, decide to save the test result in dbt command:

```bash
dbt test --vars '{dq_tools_enable_store_test_results: True}'
dbt build --vars '{dq_tools_enable_store_test_results: True}'
```

<details>
  <summary>Alternatively, we can also enable this variable in <code>dbt_project.yml`</code>:</summary>

```yml
vars:
  # to store the test results in db table
  dq_tools_enable_store_test_results: True
```

</details>

Pros & Cons:

- Pros:
  - Save both type of tests (singular and generic) result to log table
  - Save test result from any test functions (outside of dq-tools ones)
- Cons
  - Only availabe on the latest version
  - Singular Test: table_name / ref_table: cannot be captured
  - Singular Test: no_of_records cannot be captured


<details>
  <summary>For dq_tools version < 1.0 (with legacy variable) </summary>

#### Enabling test result storing by `dbt_test_results_to_db` variable

Optionally, add `dbt_test_results_to_db: False` as a variable to your `dbt_profile.yml` file. Its default value is `False` meaning NOT to save test result.

e.g.

```yaml
vars:
  # to store the test results in db table
  dbt_test_results_to_db: False
```

You can also specify the variable in dbt commands e.g.

```bash
dbt test -s your_model vars '{dbt_test_results_to_db: True}'
dbt build -s your_model vars '{dbt_test_results_to_db: True}'
```

Additionally, you **MUST** know that when you generate the doc or compile the code, this variable `dbt_test_results_to_db` is super important. If it's defined as `True`, it will run the test when generating the documentation or compiling. (indeed generating the doc compile the code first [see: Generating project documentation](https://docs.getdbt.com/docs/building-a-dbt-project/documentation#generating-project-documentation)).

So you should either pass the variable when generating the doc and compiling the code.

````bash
dbt docs generate --vars  'dbt_test_results_to_db: False'
dbt compile --vars  'dbt_test_results_to_db: False'
````

Either defined it to false in the default variables and defined the variables when running the test.

````bash
dbt test --vars  'dbt_test_results_to_db: False'
````

Pros & Cons:

- Pros:
  - Automatically save generic test result (if you used dq-tools functions)

- Cons:
  - Requires to create new test function(s) in advanced case(s) to adapt with current implementation of test result capturing approach
  - Singular test functions is not documented (?)

</details>

### 4. Decide to enable building the downstream models of the log table

Since the version 1.4+, all models and metrics will be enabled by default.

<details>
  <summary>For dq-tools version <1.4</summary>
  
  Enable it in `dbt_project.yml` file:

  ```yml
  # dbt_project.yml
  models:
    dq_tools:
      +enabled: true

  metrics:
    dq_tools:
      +enabled: true
  ```
</details>

## Macros

### on-run-end Context

#### store_test_results ([source](https://github.com/infinitelambda/dq-tools/blob/main/macros/artifacts/test/store_test_results.sql))

This macro is used to parse `results` variable at the `on-run-end` context to achieve the test result nodes, and save them to the `DQ_ISSUE_LOG` table.
If the model is materialized as `ephemeral`, this macro will insert the null value for aggregated fields related to tested model.

Usage:

```yml
# dbt_project.yml
on-run-end:
  - '{{ dq_tools.store_test_results(results) }}'
```

Besides, there are couple of private macros are used as a part of it aiming to extract/calculate things under ([here](https://github.com/infinitelambda/dq-tools/blob/main/macros/artifacts/test/utilities/))

### Generic Tests

These tests are based on dbt_utils test.
The test result will be stored in a database table and further analysis can be built on these.

Detailed informations will be stored such as check_timestamp, table_name, column_name, value, severity, no_of records etc.

#### not_null_where_db ([source](https://github.com/infinitelambda/dq-tools/blob/main/macros/generic_tests/test_not_null_where_db.sql))

This test validates that there are no null values present in a column for a subset of rows by specifying a `where` clause.

All data quality issues are stored in the dq_issues_log table.

If not specified the default severity level is 'warn'. This option coresponds with dbts severity setting.

Kpi_category option allows you to change the default category, which this test will fall into in the looker dq_mart dashboard. Accepted values are: [`Accuracy`, `Consistency`, `Completeness`, `Timeliness`, `Validity`, `Uniqueness`]. Any other value will fall into `Other`. Default option for this test is Completeness.

Usage:

```yaml
version: 2

models:
  - name: my_model
    columns:
      - name: id
        data_tests:
          - dq_tools.not_null_where_db:
              where: "_deleted = false"
              severity_level: error
              kpi_category: Completeness
```

#### relationships_where_db ([source](https://github.com/infinitelambda/dq-tools/blob/main/macros/generic_tests/test_relationships_where_db.sql))

This test validates the referential integrity between two relations (same as the core relationships schema test) with an added predicate to filter out some rows from the test. This is useful to exclude records such as test entities, rows created in the last X minutes/hours to account for temporary gaps due to ETL limitations, etc.

All data quality issues are stored in the dq_issues_log table.

If not specified the default severity level is 'warn'. This option coresponds with dbts severity setting.

Kpi_category option allows you to change the default category, which this test will fall into in the looker dq_mart dashboard. Accepted values are: [`Accuracy`, `Consistency`, `Completeness`, `Timeliness`, `Validity`, `Uniqueness`]. Any other value will fall into `Other`. Default option for this test is Consistency.

Usage:

```yaml
version: 2

models:
  - name: model_name
    columns:
      - name: id
        data_tests:
          - dq_tools.relationships_where_db:
              to: ref('other_model_name')
              field: client_id
              from_condition: id <> '4ca448b8-24bf-4b88-96c6-b1609499c38b'
              severity_level: warn
              kpi_category: Consistency

```

#### unique_where_db ([source](https://github.com/infinitelambda/dq-tools/blob/main/macros/generic_tests/test_unique_where_db.sql))

This test validates that there are no duplicate values present in a field for a subset of rows by specifying a `where` clause.

All data quality issues are stored in the dq_issues_log table.

If not specified the default severity level is 'warn'. This option coresponds with dbts severity setting.

Kpi_category option allows you to change the default category, which this test will fall into in the looker dq_mart dashboard. Accepted values are: [`Accuracy`, `Consistency`, `Completeness`, `Timeliness`, `Validity`, `Uniqueness`]. Any other value will fall into `Other`. Default option for this test is Uniqueness.

Usage:

```yaml
version: 2

models:
  - name: my_model
    columns:
      - name: id
        data_tests:
          - dq_tools.unique_where_db:
              where: "_deleted = false"
              severity_level: error
              kpi_category: Uniqueness
```

#### recency_db ([source](https://github.com/infinitelambda/dq-tools/blob/main/macros/generic_tests/test_recency_db.sql))

This schema test asserts that there is data in the referenced model at least as recent as the defined interval prior to the current timestamp.

All data quality issues are stored in the dq_issues_log table.

If not specified the default severity level is 'warn'. This option coresponds with dbts severity setting.

Kpi_category option allows you to change the default category, which this test will fall into in the looker dq_mart dashboard. Accepted values are: [`Accuracy`, `Consistency`, `Completeness`, `Timeliness`, `Validity`, `Uniqueness`]. Any other value will fall into `Other`. Default option for this test is Timeliness.

Usage:

```yaml
version: 2

models:
  - name: model_name
    data_tests:
      - dq_tools.recency_db:
          datepart: day
          field: created_at
          interval: 1
          severity_level: warn
          kpi_category: Timeliness
```

#### expression_is_true_db ([source](https://github.com/infinitelambda/dq-tools/blob/main/macros/generic_tests/test_expression_is_true_db.sql))

This schema test asserts that a valid sql expression is true for all records. This is useful when checking integrity across columns, for example, that a total is equal to the sum of its parts, or that at least one column is true.

All data quality issues are stored in the dq_issues_log table.

If not specified the default severity level is 'warn'. This option coresponds with dbts severity setting.

Kpi_category option allows you to change the default category, which this test will fall into in the looker dq_mart dashboard. Accepted values are: [`Accuracy`, `Consistency`, `Completeness`, `Timeliness`, `Validity`, `Uniqueness`]. Any other value will fall into `Other`. Default option for this test is Validity.

Usage:

```yaml
version: 2

models:
  - name: model_name
    data_tests:
      - dq_tools.expression_is_true_db:
          expression: "col_a + col_b = total"
          kpi_category: Validity

```

#### accepted_values_where_db ([source](https://github.com/infinitelambda/dq-tools/blob/main/macros/generic_tests/test_accepted_values_where_db.sql))

This schema test asserts that all of the column values are within the list of accepted values provided. As with other schema tests, optional parameter `where` can be specified for testing just a subset of the column.

All data quality issues are stored in the dq_issues_log table.

If not specified the default severity level is 'warn'. This option coresponds with dbts severity setting.

Kpi_category option allows you to change the default category, which this test will fall into in the looker dq_mart dashboard. Accepted values are: [`Accuracy`, `Consistency`, `Completeness`, `Timeliness`, `Validity`, `Uniqueness`]. Any other value will fall into `Other`. Default option for this test is Accuracy.

Usage:

```yaml
version: 2

models:
  - name: model_name
    data_tests:
      - dq_tools.accepted_values_where_db:
          values: [value1, value2]
          severity_level: warn
          kpi_category: Accuracy
```

#### equal_rowcount_where_db ([source](https://github.com/infinitelambda/dq-tools/blob/main/macros/generic_tests/test_equal_rowcount_where_db.sql))

This schema test asserts that count of rows in two relations is the same. Optional parameters `where` and `compare_model_where` can be specified for testing just a subset of base and compared relations respectively.

All data quality issues are stored in the dq_issues_log table.

If not specified the default severity level is 'warn'. This option coresponds with dbts severity setting.

Kpi_category option allows you to change the default category, which this test will fall into in the looker dq_mart dashboard. Accepted values are: [`Accuracy`, `Consistency`, `Completeness`, `Timeliness`, `Validity`, `Uniqueness`]. Any other value will fall into `Other`. Default option for this test is Consistency.

Usage:

```yaml
version: 2

models:
  - name: model_name
    data_tests:
      - dq_tools.equal_rowcount_where_db:
          compare_model: some_other_model
          where: "_deleted = false"
          compare_model_where: "_deleted = false"
          severity_level: warn
```

#### equality_where_db ([source](https://github.com/infinitelambda/dq-tools/blob/main/macros/generic_tests/test_equality_where_db.sql))

This schema test asserts that two relations (or subset of their columns) are equal. Relations as a whole are considered if the parameter `compare_columns` is not provided.
Optional parameters `where` and `compare_model_where` can be specified for testing just a subset of base and compared relations respectively.

All data quality issues are stored in the dq_issues_log table.

If not specified the default severity level is 'warn'. This option coresponds with dbts severity setting.

Kpi_category option allows you to change the default category, which this test will fall into in the looker dq_mart dashboard. Accepted values are: [`Accuracy`, `Consistency`, `Completeness`, `Timeliness`, `Validity`, `Uniqueness`]. Any other value will fall into `Other`. Default option for this test is Consistency.

Usage:

```yaml
version: 2

models:
  - name: model_name
    data_tests:
      - dq_tools.equality_where_db:
          compare_model: some_other_model
          compare_columns:
            - column1
            - column2
          where: "_deleted = false"
          compare_model_where: "_deleted = false"
          severity_level: warn
```

## Contributing

[![contributions welcome](https://img.shields.io/badge/contribution--guideline-visit-brightgreen.svg?style=for-the-badge)](https://infinitelambda.github.io/dq-tools/nav/development/contributing-guide.html)

If you've ever wanted to contribute to this tool, and a great cause, feel free to create your [Pull Request](https://github.com/infinitelambda/dq-tools/pulls), or submit a new issue via [Bug Report](https://github.com/infinitelambda/dq-tools/issues/new?assignees=&labels=&template=bug_report.md&title=[BUG]%20Describe%20it%20shortly) / [Feature Request](https://github.com/infinitelambda/dq-tools/issues/new?assignees=&labels=&template=feature_request.md&title=[FEATURE]%20Describe%20it%20shortly) 💖
