{{
  config(
    tags = ['failed']
  )
}}

select * from {{ ref('test_failures') }} where count(*) > 1 --error test should not be captured into result log