-- assignment 1:
select
year(ws.created_at) as yr,
month(ws.created_at) as mo,
count(distinct ws.website_session_id) as sessions,
count(distinct orders.website_session_id) as orders
from website_sessions ws
left join orders
on ws.website_session_id = orders.website_session_id
where ws.created_at < '2012-12-31'
group by year(ws.created_at), month(ws.created_at);



select
min(date(ws.created_at)),
count(distinct ws.website_session_id) as sessions,
count(distinct orders.website_session_id) as orders
from website_sessions ws
left join orders
on ws.website_session_id = orders.website_session_id
where ws.created_at < '2012-12-31'
group by year(ws.created_at), month(ws.created_at), week(ws.created_at);



-- assignment 2:

select
hr,
-- avg(count_) as avg_,
round(Avg(case when wk = 0 then count_ else null end),1) as mon,
round(Avg(case when wk = 1 then count_ else null end),1) as tus,
round(Avg(case when wk = 2 then count_ else null end),1) as web,
round(Avg(case when wk = 3 then count_ else null end),1) as thur,
round(Avg(case when wk = 4 then count_ else null end),1) as fri,
round(Avg(case when wk = 5 then count_ else null end),1) as sat,
round(Avg(case when wk = 6 then count_ else null end),1) as sun
from
(select 
date(created_at) as created_date,
weekday(created_at) as wk,
hour(created_at) as hr,
count(distinct website_session_id) as count_
from website_sessions
where created_at between '2012-09-15' and '2012-11-15'
group by 1,2,3) k
group by 1
order by 1;


select 
date(created_at) as created_date,
weekday(created_at) as wk,
hour(created_at) as hr,
count(distinct website_session_id) as count_
from website_sessions
where created_at between '2012-09-15' and '2012-11-15'
group by 1,2,3;


select 
date(created_at) as da,
hour(created_at) as hr,
weekday(created_at) as weekday,
count(distinct website_session_id) as count_
from website_sessions
where created_at between '2012-09-15' and '2012-11-15'
group by 1,2;








