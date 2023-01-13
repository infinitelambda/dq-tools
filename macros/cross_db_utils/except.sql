{% macro except() %}
  {{ return(adapter.dispatch('except', macro_namespace = 'dq_tools')()) }}
{% endmacro %}


{% macro default__except() %}

    except

{% endmacro %}
    
{% macro bigquery__except() %}

    except distinct

{% endmacro %}