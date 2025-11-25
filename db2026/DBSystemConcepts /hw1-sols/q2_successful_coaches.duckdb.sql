-- Find all successful coaches who have won at least one medal. List them in descending order by medal number,
-- then by name alphabetically.
--
-- Details:  A medal is credited to a coach if it shares the same country and discipline with the coach, 
-- regardless of the gender or event. Consider to use `winner_code` of one medal to decide its country.
-- Output Format: COACH_NAME|MEDAL_NUMBER

with t as (
	select code, country_code from teams group by code, country_code
),
medal_country as (
select 
    t1.discipline, 
    case when t1.country_code is not null 
        then t1.country_code 
        else athletes.country_code end 
        as country_code
from 
    (select * from medals left join t on medals.winner_code = t.code) as t1 
    left join athletes on athletes.code = t1.winner_code)

select name as coach_name, count(*) as medal_number
from medal_country, coaches
where 
    medal_country.discipline = coaches.discipline 
    and coaches.country_code = medal_country.country_code
group by code, name
order by medal_number desc, coach_name;
