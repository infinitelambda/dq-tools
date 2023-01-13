{{
  config(
    tags = ['failed']
  )
}}

select * from {{ ref('test_failures') }} where 1 = 1 --return row so that test can be failed