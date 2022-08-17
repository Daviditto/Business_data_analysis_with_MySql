use mavenfuzzyfactory;
SELECT * from website_sessions where website_session_id = 1059;
select * from website_pageviews where website_session_id = 1059;
select * from orders where website_session_id = 1059;


 SELECT 
 website_sessions.utm_content, 
 count(distinct website_sessions.website_session_id) as sessions,
 count(distinct orders.website_session_id) as orders,
 count(distinct orders.website_session_id)/count(distinct website_sessions.website_session_id) as cvt_rt
 from website_sessions
 left join orders on website_sessions.website_session_id = orders.website_session_id
 where website_sessions.website_session_id between 1000 and 2000
group by 1
order by 2 desc;
 

select utm_source, count(distinct website_session_id)
from website_sessions
where created_at< '2012-04-12'
group by utm_source;

select utm_campaign, count(distinct website_session_id)
from website_sessions
where created_at < '2012-04-12'
group by 1;

select utm_source, utm_campaign, http_referer, count(distinct website_session_id) as sessions
from website_sessions
where created_at < '2012-04-12'
group by 1, 2, 3
order by 4 desc;

select 
count(distinct website_sessions.website_session_id) as sessoins,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as CVR
from website_sessions 
left join orders on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-04-14' 
and utm_source = 'gsearch' 
and utm_campaign = 'nonbrand' 
and http_referer = 'https://www.gsearch.com';


select website_session_id, 
created_at, 
month(created_at),
year(created_at),
week(created_at)
from website_sessions 
where website_session_id between 100000 and 115000;

select 
year(created_at),
week(created_at),
min(date(created_at)),
count(distinct website_session_id) as sessions
from website_sessions 
where website_session_id between 100000 and 115000
group by 1, 2;

select order_id, primary_product_id, items_purchased,
case when items_purchased = 1 then order_id else null end as single_purchased,
case when items_purchased = 2 then order_id else null end as two_purchased
from orders 
where order_id between 31000 and 32000;

select 
order_id, 
primary_product_id, 
items_purchased,
count(distinct case when items_purchased = 1 then order_id else null end) as single_purchased,
count(distinct case when items_purchased = 2 then order_id else null end) as two_purchased
from orders 
where order_id between 31000 and 32000
group by 1,2,3;

select primary_product_id, 
count(distinct case when items_purchased=1 then order_id else null end) as  order_1_item,
count(distinct case when items_purchased=2 then order_id else null end) as order_2_item,
count(distinct order_id) as total_orders
from orders
where order_id between 31000 and 32000
group by 1;

select 
-- week(created_at),
min(date(created_at)), 
count(distinct website_session_id)
from website_sessions
where  created_at < '2012-05-12'
and utm_source= 'gsearch'
and utm_campaign = 'nonbrand'
group by week(created_at)
order by 1;

select website_sessions.device_type, 
count(distinct website_sessions.website_session_id),
count(distinct orders.order_id),
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id)
from website_sessions left join orders on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-05-11'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by 1;


select 
-- week(created_at),
min(date(created_at)), 
count(distinct case when device_type='desktop' then website_session_id else null end) as desktop,
count(distinct case when device_type='mobile' then website_session_id else null end) as mobile,
count(distinct website_session_id)
from website_sessions
where created_at between '2012-04-15' and '2012-06-09'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by week(created_at);



 
 
