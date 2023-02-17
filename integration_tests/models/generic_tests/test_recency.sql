{% if target.type == 'postgres' -%}

select {{ date_trunc('day', dq_tools.current_timestamp()) }} as today

{% else %}

select cast({{ date_trunc('day', dq_tools.current_timestamp()) }} as datetime) as today

{%- endif %}