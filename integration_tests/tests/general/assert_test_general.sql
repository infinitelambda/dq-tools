/*
  aim to have a singular test related to a model
*/
select  *
from    {{ ref('test_general') }}
where   col < 0