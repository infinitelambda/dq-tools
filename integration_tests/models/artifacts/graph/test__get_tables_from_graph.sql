select -1 as actual, -1 as expected
{% if execute -%}

  {% set nodes = [] -%}
  {% do nodes.extend(graph.sources.values()) -%}
  {% do nodes.extend(graph.nodes.values() | selectattr("resource_type", "in", ['model','snapshot','seed'])) -%}

  union all
  select  {{ dq_tools.__get_tables_from_graph() | length }} as actual
          ,{{ nodes | length }} as expected

{%- endif %}
