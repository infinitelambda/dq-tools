{% macro __get_test_description(test_node) %}

    {{ return(adapter.dispatch('__get_test_description', 'dq_tools')(test_node)) }}

{% endmacro %}

{% macro default____get_test_description(test_node) %}

    {%- set test_type = test_node.test_metadata.name -%}
    {%- set column_name = test_node.test_metadata.kwargs.column_name -%}
    {%- set testing_model = dq_tools.__get_test_model(test_node) -%}
    {%- set model_name = dq_tools.__get_relation(testing_model).name | lower -%}

    {% if test_node.description is defined and test_node.description %}

        {{ return(test_node.description) }}
    
    {% else %}

        {%- set generated_description = '' -%}

        {%- if test_type == 'unique' -%}
            {%- set generated_description = 'The ' ~ column_name ~ ' column in the ' ~ model_name ~ ' model should be unique.' -%}
        {%- elif test_type == 'not_null' -%}
            {%- set generated_description = 'The ' ~ column_name ~ ' column in the ' ~ model_name ~ ' model should not contain null values.' -%}
        {%- elif test_type == 'accepted_values' -%}
            {%- set accepted_values = test_node.test_metadata.kwargs['values'] | join(', ') -%}
            {%- set generated_description = 'The ' ~ column_name ~ ' column in the ' ~ model_name ~ ' should be one of ' ~ accepted_values ~ ' values.' -%}
        {%- elif test_type == 'relationships' -%}
            {%- set to_model = test_node.test_metadata.kwargs.to -%}
            {%- set related_model = to_model.split('\'')[1].strip() -%}
            {%- set generated_description = 'Each ' ~ column_name ~ ' in the ' ~ model_name ~ ' model exists as an id in the ' ~ related_model ~ ' table.' -%}
        {%- endif -%}

        {{ return(generated_description) }}

    {% endif %}

{% endmacro %}
