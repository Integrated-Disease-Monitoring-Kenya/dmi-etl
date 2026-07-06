with age_group_data as (

    select *
    from (
        values
            ('<1',      0,   0),
            ('1-4',     1,   4),
            ('5-14',    5,  14),
            ('15-24',  15,  24),
            ('25-49',  25,  49),
            ('50+',    50, 200),
            ('Unknown', null, null)
    ) as age_groups(age_group, min_age, max_age)

),

final as (

    select
        {{ dbt_utils.surrogate_key(['age_group']) }} as age_group_key,
        age_group,
        min_age,
        max_age,
        current_date as load_date
    from age_group_data

)

select *
from final