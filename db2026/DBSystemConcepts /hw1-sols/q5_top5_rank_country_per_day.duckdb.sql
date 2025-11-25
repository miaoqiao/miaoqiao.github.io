-- For each day, find the country with the highest number of appearances in the top 5 ranks (inclusive) of 
-- that day. For these countries, also list their population rank and GDP rank. Sort the output by date in 
-- ascending order.
--
-- Details: Only consider records from the `results` table where `rank` is not null when counting appearances.
-- Exclude days where all `rank` values are null from the output. In case of a tie in the number of
-- appearances, select the country that comes first alphabetically.  Keep the original format of the date.
-- Hint: Use the `result` table, and use the `participant_code` to get the corresponding country. If you cannot
-- get the country information for a record in the `result` table, ignore that record.
-- Output Format: DATE|COUNTRY_CODE|TOP5_APPEARANCES|GDP_RANK|POPULATION_RANK

with t as (
	select code, country_code from teams group by code, country_code
),
country_rank as (
select
    code,
    rank() over (order by "GDP ($ per capita)" desc) as gdp_rank,
    rank() over (ORDER BY "Population" desc) as population_rank
from
    countries
)

select 
    date, 
    country as country_code, 
    num as top5_appearances, 
    country_rank.gdp_rank as gdp_rank, 
    country_rank.population_rank as population_rank
from
    (select 
        *,
        row_number() over (partition by date order by num desc, country) as row_number
    from
        (select 
            date, 
            case when t1.country_code is not null then t1.country_code else athletes.country_code end as country, 
            count(*) as num
        from 
            (select * from results left join t on results.participant_code = t.code) 
            as t1 
            left join athletes on t1.participant_code = athletes.code
        where rank <= 5
        group by date, country)
    ) as t, country_rank
where row_number = 1 and country_rank.code = t.country
order by date;
