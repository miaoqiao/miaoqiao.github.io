-- List the five countries with the greatest improvement in the number of gold medals compared to the Tokyo
-- Olympics. For each of these five countries, list all their all-female teams. Sort the output first by
-- the increased number of gold medals in descending order, then by country code alphabetically, and last by
-- team code alphabetically.
--
-- Details: When calculating all-female teams, if the `athlete_code` in a record from the `teams` table is
-- not found in the `athletes` table, please ignore this record as if it doesn't exist.
-- Hints: You might find Lateral Joins in DuckDB useful: find out the 5 countries with largest progress first,
-- and then use lateral join to find their all-female reams.
-- Output Format: COUNTRY_CODE|INCREASED_GOLD_MEDAL_NUMBER|TEAM_CODE

with t as (
	select code, country_code from teams group by code, country_code
),
paris_medals as (
    select t2.country_code as country_code, count(t2.country_code) as medal_number 
    from
        (select 
            t1.medal_code, 
            case when t1.country_code is not null then t1.country_code else athletes.country_code end as country_code
        from 
            (select * from medals left join t on medals.winner_code = t.code) as t1 
            left join athletes on athletes.code = t1.winner_code
        ) as t2, 
        medal_info mi
    where t2.medal_code = mi.code and mi.name = 'Gold Medal'
    group by t2.country_code
    order by medal_number desc
)

select country as country_code, progress as increased_gold_medal_number, code as team_code
from (
    select 
        paris_medals.country_code as country, 
        paris_medals.medal_number - tokyo_medals.gold_medal as progress
    from tokyo_medals, paris_medals
    where paris_medals.country_code = tokyo_medals.country_code
    order by progress desc
    limit 5
) as countries, lateral (
    select teams.code as code
    from teams, athletes 
    where teams.athletes_code = athletes.code and teams.country_code = countries.country
    group by teams.code
    having sum(1 - gender) = 0
    )
order by progress desc, country, code;
