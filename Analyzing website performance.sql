use mavenfuzzyfactory;

select 
pageview_url,
count(distinct website_session_id)
from website_pageviews
where website_pageview_id < 1000
group by 1
order by 2 desc;


select *
from website_pageviews
where website_pageview_id < 1000;

select 
website_pageview_id, 
min(website_session_id)
from website_pageviews 
where website_pageview_id < 1000
group by website_session_id;


create temporary table first_pageview as
select 
website_pageview_id, 
min(website_session_id) as min_pv
from website_pageviews 
where website_pageview_id < 1000
group by website_session_id;


select * from first_pageview;

select 
wp.website_session_id,
wp.pageview_url
from first_pageview fp
left join website_pageviews wp
on fp.website_pageview_id = wp.website_pageview_id;

select 
wp.pageview_url as landing_page,
count(distinct wp.website_session_id) as sessions_hitted
from first_pageview fp
left join website_pageviews wp
on fp.website_pageview_id = wp.website_pageview_id
group by landing_page;


select 
pageview_url,
count(distinct website_session_id)
from website_pageviews
where created_at < '2012-06-09'
group by pageview_url
order by 2 desc;

create temporary table first_pv_per_session1 as
select  
website_session_id,
min(website_pageview_id) as first_pv
from website_pageviews
where created_at < '2012-06-12'
group by 1;

select * from first_pv_per_session1;


select 
wp.pageview_url,
count(wp.pageview_url)
from first_pv_per_session1 fp
left join website_pageviews wp
on fp.first_pv = wp.website_pageview_id
group by wp.pageview_url;


select 
ws.website_session_id,
min(wp.website_pageview_id) as landing_site
from website_pageviews wp
inner join website_sessions ws
on wp.website_session_id = ws.website_session_id
and ws.created_at between '2014-01-01' and '2014-02-01'
group by ws.website_session_id;


create temporary table landing_site as
select 
ws.website_session_id,
min(wp.website_pageview_id) as landing_site
from website_pageviews wp
inner join website_sessions ws
on wp.website_session_id = ws.website_session_id
and ws.created_at between '2014-01-01' and '2014-02-01'
group by ws.website_session_id;

select * from landing_site;

create temporary table landing_page as
select 
ls.website_session_id,
wp.pageview_url as landing_page
from landing_site ls
left join website_pageviews wp
on ls.landing_site = wp.website_pageview_id;

select * from landing_page;

select 
count(distinct ls.website_session_id),
wp.pageview_url as landing_page
from landing_site ls
left join website_pageviews wp
on ls.landing_site = wp.website_pageview_id
group by 2; -- this one i did it myself just for fun



create temporary table bounce_session_only as
select 
lp.website_session_id,
lp.landing_page,
count(wp.website_session_id) as num_of_page_viewed
from landing_page lp
left join website_pageviews wp
on lp.website_session_id = wp.website_session_id
group by lp.website_session_id, lp.landing_page
having num_of_page_viewed =1;

select * from bounce_session_only;

select 
	landing_page.landing_page,
	landing_page.website_session_id, 
	bounce_session_only.website_session_id as bounce_session_id
from landing_page 
	left join bounce_session_only 
	on landing_page.website_session_id = bounce_session_only.website_session_id
    order by 2; 

select 
	landing_page.landing_page,
	count(distinct landing_page.website_session_id) as num_landing_session, 
	count(bounce_session_only.website_session_id) as num_bounce_session,
    count(bounce_session_only.website_session_id)/count(distinct landing_page.website_session_id) as bounce_rate
from landing_page 
	left join bounce_session_only 
	on landing_page.website_session_id = bounce_session_only.website_session_id
    group by 1; 
    



select 
ls.website_session_id,
ls.landing_site,
wp.pageview_url
from 
(select wp.website_session_id,
min(website_pageview_id) as landing_site
from website_pageviews wp
where wp.created_at < '2012-06-14'
group by 1) ls
left join website_pageviews wp
on ls.landing_site = wp.website_pageview_id;








-- finish it in one query
select 
landing_page.pageview_url,
count(distinct landing_page.website_session_id) as sessions,
count(distinct bounce_only.website_session_id) as bounce_session,
count(distinct bounce_only.website_session_id)/ count(distinct landing_page.website_session_id) as bounce_rate
from 
(select 
ls.website_session_id,
ls.landing_site,
wp.pageview_url
from 
(select wp.website_session_id,
min(website_pageview_id) as landing_site
from website_pageviews wp
where wp.created_at < '2012-06-14'
group by 1) ls
left join website_pageviews wp
on ls.landing_site = wp.website_pageview_id) landing_page

left join 

(select
landing_page.website_session_id,
landing_page.pageview_url,
count(wp.website_session_id) as bounce_view
from 
(select 
ls.website_session_id,
ls.landing_site,
wp.pageview_url
from 
(select wp.website_session_id,
min(website_pageview_id) as landing_site
from website_pageviews wp
where wp.created_at < '2012-06-14'
group by 1) ls
left join website_pageviews wp
on ls.landing_site = wp.website_pageview_id) landing_page
left join website_pageviews wp
on landing_page.website_session_id = wp.website_session_id
group by landing_page.website_session_id
having bounce_view = 1) bounce_only

on 
landing_page.website_session_id = bounce_only.website_session_id
group by landing_page.pageview_url;




select 
web.website_session_id,
wp.website_pageview_id,
min(wp.created_at),
wp.pageview_url
from 
(select 
website_session_id
from website_sessions
where created_at < '2012-07-28'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand') web

inner join
website_pageviews wp
where web.website_session_id = wp.website_session_id
and wp.pageview_url = '/lander-1';



create temporary table working_data as
select
wp.website_pageview_id,
select_data.website_session_id,
pageview_url
from
(select 
website_session_id
from website_sessions
where created_at between '2012-06-19' and '2012-07-28'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand') select_data
inner join
website_pageviews wp
on select_data.website_session_id = wp.website_session_id;

select * from working_data;


create temporary table landing_page2 as
select 
landing_site.landing_site,
wp.pageview_url as landing_page,
wp.website_session_id
from
(select 
wd.pageview_url,
wd.website_session_id,
min(wd.website_pageview_id) as landing_site
from working_data wd
group by wd.website_session_id) landing_site

left join website_pageviews wp
on landing_site.landing_site = wp.website_pageview_id;


select * from landing_page2;


create temporary table bounce_seeion
select 
lp.landing_site, 
wp.website_session_id,
wp. pageview_url,
count(lp.website_session_id) as bounce
from landing_page2 lp
left join
website_pageviews wp
on lp.website_session_id = wp.website_session_id
group by wp.website_session_id
having bounce =1;


select * from bounce_seeion;


select 
l2.landing_page,
count(l2.website_session_id) as sessions,
count(bs.website_session_id) as bounces,
count(bs.website_session_id)/count(l2.website_session_id) as bounce_rate
from landing_page2 l2
left join bounce_seeion bs
on l2.website_session_id = bs.website_session_id
group by l2.landing_page
order by l2.landing_page; 






create temporary table working_data2 as
select 
wp.created_at,
selected.website_session_id,
wp.website_pageview_id,
wp.pageview_url
from 
(select
website_session_id
from website_sessions
where created_at between '2012-06-01' and '2012-08-31'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand') selected
inner join
website_pageviews wp
on selected.website_session_id = wp.website_session_id;

select * from working_data2;


create temporary table landing_p1 as
select 
landing_site.landing_site as website_pageview_id,
wp.website_session_id,
wp.pageview_url,
wp.created_at
from 
(select 
website_session_id,
min(website_pageview_id) as landing_site
from working_data2
group by website_session_id) landing_site
left join website_pageviews wp
on landing_site.landing_site = wp.website_pageview_id;

select * from landing_p1;

select 
min(date(landing_p1.created_at)) as week_start_date,
count(bounce_num.website_session_id) as bounce_sessions,
count(landing_p1.website_session_id) as total_sessions,
count(bounce_num.website_session_id)/ count(landing_p1.website_session_id) as bounce_rate,
count(case when landing_p1.pageview_url = '/home' then landing_p1.website_session_id else null end) as home_sessions,
count(case when landing_p1.pageview_url = '/lander-1' then landing_p1.website_session_id else null end) as lander_sessions
from landing_p1
left join
(select 
landing_p.pageview_url,
landing_p.website_session_id,
count(wp.website_pageview_id) as num
from landing_p
left join website_pageviews wp
on landing_p.website_session_id = wp.website_session_id
group by landing_p.website_session_id
having num = 1) bounce_num
on landing_p1.website_session_id = bounce_num.website_session_id
group by week(landing_p1.created_at);





