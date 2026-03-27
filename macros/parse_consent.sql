{% macro parse_consent(column_name) %}
    case
        when {{ column_name }} is null or trim({{ column_name }}) = '' then null
        when upper(trim({{ column_name }})) like 'OTHER%' then 99
        when trim({{ column_name }}) ~ '^\d+$' then cast(trim({{ column_name }}) as integer)
        else null
    end
{% endmacro %}