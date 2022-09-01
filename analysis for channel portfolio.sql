use mavenfuzzyfactory;
-- the example
select 
ws.utm_content,
count(distinct ws.website_session_id) as sessions,
count(distinct orders.website_session_id) as orders,
count(distinct orders.website_session_id)/count(distinct ws.website_session_id) as cvt_rt
from website_sessions ws
left join orders
on ws.website_session_id = orders.website_session_id
where ws.created_at between '2014-01-01' and '2014-02-01'
group by ws.utm_content
order by 2 desc;


-- assignment 1:

select 
min(date(created_at)),
count(distinct case when utm_source = 'gsearch' then website_session_id else null end) as g_sessions,
count(distinct case when utm_source = 'bsearch' then website_session_id else null end) as b_sessions
from website_sessions
where utm_source in ('gsearch','bsearch')
and created_at between '2012-08-22' and '2012-11-29'
and utm_campaign = 'nonbrand'
group by week(created_at);


-- assignment 2:
create temporary table sub as 
select 
website_session_id,
utm_source,
device_type
from 
website_sessions ws
where ws.utm_source in ('gsearch','bsearch')
and ws.created_at between '2012-08-22' and '2012-11-30'
and ws.utm_campaign = 'nonbrand';

select * from sub;



select 
sub.utm_source,
count(distinct sub.website_session_id) as sessions,
count(distinct ws1.website_session_id) as mobile_sessions,
count(distinct ws1.website_session_id)/count(distinct sub.website_session_id) as mobile_pct
from
sub
left join 
(select 
website_session_id,
utm_source,
device_type
from 
website_sessions ws
where ws.utm_source in ('gsearch','bsearch')
and ws.created_at between '2012-08-22' and '2012-11-30'
and ws.utm_campaign = 'nonbrand'
and ws.device_type = 'mobile')ws1
on sub.website_session_id = ws1.website_session_id
group by 1;


-- assignment 3:

create temporary table sub3 as
select 
ws.website_session_id,
ws.utm_source,
ws.device_type
from 
website_sessions ws
where ws.created_at between '2012-08-22' and '2012-09-19'
and ws.utm_source in ('gsearch', 'bsearch')
and ws.device_type in ('mobile', 'desktop')
and ws.utm_campaign = 'nonbrand';




select 
sub3.device_type,
sub3.utm_source,
count(distinct sub3.website_session_id) as sessions,
count(distinct orders.website_session_id) as orders,
count(distinct orders.website_session_id)/count(distinct sub3.website_session_id) as cvt_rt
from sub3
left join orders
on sub3.website_session_id = orders.website_session_id
group by 1,2
order by 1;

-- assignment 4:

select 
min(date(created_at)),
count(case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) as g_d_sessions,
count(case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end) as b_d_sessions,
count(case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end)/count(case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) as b_pct_g_dp,
count(case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) as g_m_sessions,
count(case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) as b_m_sessions,
count(case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end)/count(case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) as b_pct_g_mb

from website_sessions
where created_at between  '2012-11-04'  and '2012-12-22'
and utm_source in ('gsearch', 'bsearch')
and utm_campaign = 'nonbrand'
and device_type in ('mobile', 'desktop')
group by year(created_at),
week(created_at);

-- assignment 5:
select * from website_sessions;


create temporary table sub4 as
select 
*,
case 
	when utm_source is null and http_referer is null then 'direct_type_in'
    when utm_source is null and http_referer is not null then 'organic'
    else 'other' end as other
from website_sessions;

select 
year(created_at) as yr,
month(created_at) as mo,
count(case when utm_campaign ='nonbrand' then website_session_id else null end) as nonbrand,
count(case when utm_campaign ='brand' then website_session_id else null end) as brand,
count(case when utm_campaign ='brand' then website_session_id else null end)/count(case when utm_campaign ='nonbrand' then website_session_id else null end) as brand_pct_of_nonbrand,
count(case when other='direct_type_in' then website_session_id else null end) as direct,
count(case when other='direct_type_in' then website_session_id else null end)/count(case when utm_campaign ='nonbrand' then website_session_id else null end) as dierct_pct_of_nonbrand,
count(case when other = 'organic' then website_session_id else null end) as organic,
count(case when other = 'organic' then website_session_id else null end)/count(case when utm_campaign ='nonbrand' then website_session_id else null end)  as organic_pct_of_nonbrand
from sub4
where created_at< '2012-12-23'
group by 
year(created_at), month(created_at);










