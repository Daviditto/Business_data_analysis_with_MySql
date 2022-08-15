-- assignment 1:

select
counts,
count(user_id)
from
(select
b.user_id,
count(is_repeat_session) as counts
from
(select 
website_session_id,
user_id
from website_sessions
where created_at >= '2014-01-01'
and created_at <  '2014-11-01'
and is_repeat_session = 0) b
left join website_sessions ws
on b.user_id = ws.user_id
and ws.is_repeat_session = 1 # some might not be able to bigger than b.website_session_id
and b.website_session_id < ws.website_session_id
and ws.created_at >= '2014-01-01'
and ws.created_at <  '2014-11-01'
group by b.user_id) j
group by counts
order by 1;



-- assignment 2:



create temporary table tb as
select
b.user_id,
b.created_at,
ws.created_at as return_date,
is_repeat_session
from
(select 
created_at,
website_session_id,
user_id
from website_sessions
where created_at >= '2014-01-01'
and created_at <  '2014-11-01'
and is_repeat_session = 0) b
inner join website_sessions ws
on b.user_id = ws.user_id
and ws.is_repeat_session = 1
-- and b.website_session_id < ws.website_session_id
and ws.created_at >= '2014-01-01'
and ws.created_at <  '2014-11-01';


select 
avg(diff) as avg_days,
min(diff) as maximal_days,
max(diff)as minimal_days
from
(select 
user_id,
created_at,
min(return_date),
datediff(min(return_date), created_at) as diff
from tb
group by user_id)k;



-- assignment 3:

select
case 
when utm_source is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then 'organic_search'
when utm_source is null and http_referer is null then 'direct_type_in'
when utm_campaign = 'brand' then 'paid_brand'
when utm_campaign = 'nonbrand' then 'paid_nonbrand'
when utm_source = 'socialbook' then 'paid_social'
end as channel_group,
-- utm_source,
-- utm_campaign,
-- http_referer,
count(case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
count(case when is_repeat_session = 1 then website_session_id else null end) as repeat_sessions
from 
website_sessions
where created_at >= '2014-01-01'
and created_at <  '2014-11-05'
group by 1
order by 1;


-- assignment 4:

select 
-- ws.website_session_id,
ws.is_repeat_session,
count(ws.website_session_id) as sessions,
count(orders.website_session_id)/count(ws.website_session_id) as conv_rt,
sum(orders.price_usd)/count(ws.website_session_id)
from website_sessions ws
left join orders
on ws.website_session_id = orders.website_session_id
where ws.created_at >= '2014-01-01'
and ws.created_at <  '2014-11-08'
group by 1;

 
