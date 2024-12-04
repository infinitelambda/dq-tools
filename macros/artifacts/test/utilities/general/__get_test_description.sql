{% macro __get_test_description(test_node) %}

    {{ return(adapter.dispatch('__get_test_description', 'dq_tools')(test_node)) }}

{% endmacro %}

{% macro default____get_test_description(test_node) %}

    {% if test_node.description is defined and test_node.description %}
        
        {{ return(test_node.description) }}
    
    {% elif dq_tools.__get_test_type(test_node) != 'singular' and var("dq_tools__auto_generate_test_description", "0") == "1" %}

        {%- set test_name = dq_tools.__get_test_name(test_node) -%}
        {%- set column_name = dq_tools.__get_column_name(test_node) -%}
        {%- set testing_model = dq_tools.__get_test_model(test_node) -%}
        {%- set model_name = dq_tools.__get_relation(testing_model).name | lower -%}

        {%- set generated_description = '' -%}

        {%- if test_name == 'unique' -%}
            {%- set generated_description = 'The ' ~ column_name ~ ' column in the ' ~ model_name ~ ' model should be unique.' -%}
        {%- elif test_name == 'not_null' -%}
            {%- set generated_description = 'The ' ~ column_name ~ ' column in the ' ~ model_name ~ ' model should not contain null values.' -%}
        {%- elif test_name == 'accepted_values' -%}
            {%- set accepted_values = test_node.test_metadata.kwargs['values'] | join(', ') -%}
            {%- set generated_description = 'The ' ~ column_name ~ ' column in the ' ~ model_name ~ ' should be one of ' ~ accepted_values ~ ' values.' -%}
        {%- elif test_name == 'relationships' -%}
            {%- set to_model = test_node.test_metadata.kwargs.to -%}
            {%- set related_model = to_model.split('\'')[1].strip() -%}
            {%- set generated_description = 'Each ' ~ column_name ~ ' in the ' ~ model_name ~ ' model exists as an id in the ' ~ related_model ~ ' table.' -%}
        {%- endif -%}

        {{ return(generated_description) }}

    {% endif %}

    {{ return('') }}

{% endmacro %}
