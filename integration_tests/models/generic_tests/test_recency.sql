{% if target.type == 'postgres' -%}

select {{ date_trunc(dq_tools.current_timestamp(), 'day') }} as today

{% else %}

select cast({{ date_trunc(dq_tools.current_timestamp()) }} as datetime, 'day') as today

{%- endif %}
