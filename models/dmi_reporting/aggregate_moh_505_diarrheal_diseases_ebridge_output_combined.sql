{# with
    model_output_data as (
        select
            county,
            sub_county,
            epi_week,
            year,
            year_epi_week,
            sub_county_iso_code,
            county_iso_code,
            population,
            predicted_cases,
            incidence,
            predicted_diseases
        from {{ ref("ebridge_diarrhoeal_model_output") }} as model_output
    )
select
    model_output_data.county,
    model_output_data.sub_county,
    model_output_data.epi_week,
    model_output_data.year,
    model_output_data.year_epi_week,
    model_output_data.sub_county_iso_code,
    model_output_data.county_iso_code,
    model_output_data.population,
    model_output_data.predicted_cases,
    model_output_data.incidence,
    model_output_data.predicted_diseases,
    moh_505.typhoid_fever_cases,
    moh_505.dysentery_cases,
    moh_505.cholera_cases,
    moh_505.total_cases
from model_output_data
left join
    {{ ref("aggregate_moh_505_diarrheal_diseases_report") }} as moh_505
    on moh_505.county = model_output_data.county
    and moh_505.sub_county = model_output_data.sub_county
    and moh_505.year_epi_week = model_output_data.year_epi_week
where predicted_diseases = 'Diarrhoeal Diseases'
 #}




WITH model_output_data AS (
    SELECT
        county,
        sub_county,
        epi_week,
        year,
        year_epi_week,
        sub_county_iso_code,
        county_iso_code,
        population,
        predicted_cases,
        incidence,
        predicted_diseases
    FROM {{ ref("ebridge_diarrhoeal_model_output") }}
    WHERE predicted_diseases = 'Diarrhoeal Diseases'
)

SELECT
    COALESCE(moh_505.county, model_output_data.county) AS county,
    COALESCE(moh_505.sub_county, model_output_data.sub_county) AS sub_county,
    COALESCE(moh_505.epi_week, model_output_data.epi_week) AS epi_week,
    COALESCE(moh_505.year, model_output_data.year) AS year,
    COALESCE(moh_505.year_epi_week, model_output_data.year_epi_week) AS year_epi_week,

    model_output_data.sub_county_iso_code,
    model_output_data.county_iso_code,
    model_output_data.population,
    model_output_data.predicted_cases,
    model_output_data.incidence,
    COALESCE(model_output_data.predicted_diseases, 'Diarrhoeal Diseases') AS predicted_diseases,
    moh_505.typhoid_fever_cases,
    moh_505.dysentery_cases,
    moh_505.cholera_cases,
    moh_505.total_cases,

    CASE
        WHEN moh_505.sub_county IS NULL THEN 'Only in model output'
        WHEN model_output_data.sub_county IS NULL THEN 'Only in MOH 505'
        ELSE 'Matched in both'
    END AS match_status

FROM model_output_data

FULL OUTER JOIN 
 {{ ref("aggregate_moh_505_diarrheal_diseases_report") }} as moh_505
    ON moh_505.county = model_output_data.county
    AND moh_505.sub_county = model_output_data.sub_county
    AND moh_505.year_epi_week = model_output_data.year_epi_week
