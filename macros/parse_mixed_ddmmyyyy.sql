{% macro parse_mixed_ddmmyyyy(column_name, return_type='date') %}
    case
        when {{ column_name }} is null or trim({{ column_name }}) = '' then null
        when {{ column_name }} ~ '^\d{1,2}/\d{1,2}/\d{4}\s+\d{1,2}:\d{2}$' then
            {% if return_type == 'date' %}
                to_timestamp({{ column_name }}, 'DD/MM/YYYY HH24:MI')::date
            {% else %}
                to_timestamp({{ column_name }}, 'DD/MM/YYYY HH24:MI')
            {% endif %}
        when {{ column_name }} ~ '^\d{1,2}/\d{1,2}/\d{4}$' then
            {% if return_type == 'date' %}
                to_date({{ column_name }}, 'DD/MM/YYYY')
            {% else %}
                to_timestamp({{ column_name }} || ' 00:00', 'DD/MM/YYYY HH24:MI')
            {% endif %}
        else null
    end
{% endmacro %}