{% macro __get_tables_from_graph() %}

    {% set nodes = [] %}
    {% if  execute %}
        {% do nodes.extend(graph.sources.values()) %}
        {% do nodes.extend(graph.nodes.values() | selectattr("resource_type", "in", ['model','snapshot','seed'])) %}
    {% endif %}
    {{ return(nodes) }}

{% endmacro %}