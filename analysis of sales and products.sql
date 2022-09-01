-- analysis of sales and products

select 
primary_product_id,
sum(price_usd) as avenue,
sum(price_usd - cogs_usd) as margin,
avg(price_usd) as aov
from orders
group by 1
order by 2;


--  assignment 1:

select 
year(created_at) as yr,
month(created_at) as mo,
count(order_id) num_of_sales,
round(sum(price_usd),2) as total_avenue,
round(sum(price_usd - cogs_usd),2) as total_margin
from orders 
where created_at < '2013-01-04'
group by year(created_at),
month(created_at);


-- assignment 2:
create temporary table tab1 as
select 
 ws.website_session_id,
 ws.created_at,
 year(ws.created_at) as yr,
 month(ws.created_at) as mo,
 orders.primary_product_id,
 orders.website_session_id as orders,
 orders.price_usd,
 orders.cogs_usd
from website_sessions ws
left join orders
on ws.website_session_id = orders.website_session_id
where ws.created_at between '2012-04-1' and '2013-04-01'
group by 1,year(ws.created_at), month(ws.created_at);



select
year(created_at) as yr,
month(created_at) as mo,
count(website_session_id) as sessions,
count(orders) as orders,
count(orders)/count(website_session_id) as conv_rate,
sum(price_usd)/count(website_session_id) as revenue_per_session,
count(case when primary_product_id=1 then orders else null end) as product_1_orders,
count(case when primary_product_id=2 then orders else null end) as product_2_orders
from tab1 
group by year(created_at), month(created_at);


-- assignment 3:
-- pre exercise:

select distinct pageview_url from website_pageviews;



select 
wp.pageview_url,
count(wp.website_session_id) as sessions,
count(orders.website_session_id) as orders,
count(orders.website_session_id)/count(wp.website_session_id) as covt_rt
from website_pageviews wp
left join orders
on wp.website_session_id = orders.website_session_id
where wp.pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear')
group by 1;


create temporary table tab2 as 
select 
date(created_at),
case when created_at < '2013-01-06' then 'pre_product' else 'post_product'end as time_peroid,
website_session_id,
pageview_url, 
max(case when pageview_url = '/products' then 1 else 0 end) as products,
max(case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end) as fuzzy,
max(case when pageview_url = '/the-forever-love-bear' then 1 else 0 end) as bear
from website_pageviews
where pageview_url in ('/products','/the-original-mr-fuzzy', '/the-forever-love-bear')
and created_at between '2012-10-06' and '2013-04-06'
group by 3;

select * from tab2;


select 
time_peroid,
count(case when products=1 then 1 else null end) as sessions,
count(case when fuzzy=1 then 1 else null end) + count(case when bear=1 then 1 else null end) as w_next_page,
(count(case when fuzzy=1 then 1 else null end) + count(case when bear=1 then 1 else null end))/count(case when products=1 then 1 else null end) as pct_with_next_page,
count(case when fuzzy=1 then 1 else null end) as to_fuzzy,
count(case when fuzzy=1 then 1 else null end) / count(case when products=1 then 1 else null end) as pct_to_fuzzy,
count(case when bear=1 then 1 else null end) as to_bear,
count(case when bear=1 then 1 else null end)/count(case when products=1 then 1 else null end) as pct_to_bear
from tab2 group by time_peroid;



-- assignment 4:
select min(created_at) from website_pageviews
where pageview_url = '/the-forever-love-bear';



-- create temporary table tab3 as 



create temporary table tab3 as
select 
product_seen,
website_session_id,
max(case when pageview_url='/cart'                  then 1 else 0 end) as cart,
max(case when pageview_url='/shipping'              then 1 else 0 end) as shipping,
max(case when pageview_url= '/billing-2'              then 1 else 0 end) as billing,
max(case when pageview_url='/thank-you-for-your-order' then 1 else 0 end) as thanks
from 
(select 
tb.pageview_url as product_seen,
wp.pageview_url,
tb.website_session_id
from
(select 
website_session_id,
pageview_url
from website_pageviews
where created_at between '2013-01-06' and '2013-04-10'
and pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear'))tb
left join website_pageviews wp
on tb.website_session_id = wp.website_session_id
where wp.pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear','/cart','/shipping','/billing-2','/thank-you-for-your-order')
and wp.created_at between '2013-01-06' and '2013-04-10'
order by 3) k
group by 2;





-- before the creation of the tab3 table 
select 
tb.pageview_url as product_seen,
wp.pageview_url,
tb.website_session_id
from
(select 
website_session_id,
pageview_url
from website_pageviews
where created_at between '2013-01-06' and '2013-04-10'
and pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear'))tb
left join website_pageviews wp
on tb.website_session_id = wp.website_session_id
where wp.pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear','/cart','/shipping','/billing-2','/thank-you-for-your-order')
and wp.created_at between '2013-01-06' and '2013-04-10'
order by 3;


select 
case when product_seen = '/the-original-mr-fuzzy' then 'mrfuzzy'
when product_seen = '/the-forever-love-bear' then 'lovebear'
else null end as product_seen,
count(website_session_id),
count(case when cart = 1 then 1 else null end) as to_cart,
count(case when shipping = 1 then 1 else null end) to_shipping,
count(case when billing = 1 then 1 else null end) to_billing,
count(case when thanks = 1 then 1 else null end) to_thanks
from tab3
group by 1
order by 2;

select 
case when product_seen = '/the-original-mr-fuzzy' then 'mrfuzzy'
when product_seen = '/the-forever-love-bear' then 'lovebear'
else null end as product_seen,
-- count(website_session_id),
count(case when cart = 1 then 1 else null end)/count(website_session_id) as product_click_thru,
count(case when shipping = 1 then 1 else null end)/count(case when cart = 1 then 1 else null end) as cart_click_thru,
count(case when billing = 1 then 1 else null end)/ count(case when shipping = 1 then 1 else null end) as shipping_click_thru,
count(case when thanks = 1 then 1 else null end)/count(case when billing = 1 then 1 else null end) as billing_click_thru
from tab3
group by 1
order by 2 desc;






-- another way to do it
select
case when fuzzy = 1 then 'mrfuzzy'
when bear = 1 then 'lovebear'
else null end as product_seen,
count(website_session_id),
count(case when cart = 1 then 1 else null end) as to_cart,
count(case when shipping = 1 then 1 else null end) to_shipping,
count(case when billing = 1 then 1 else null end) to_billing,
count(case when thanks = 1 then 1 else null end) to_thanks
from
(select 
website_session_id,
pageview_url,
max(case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end) as fuzzy,
max(case when pageview_url='/the-forever-love-bear' then 1 else 0 end) as bear,
max(case when pageview_url='/cart'                  then 1 else 0 end) as cart,
max(case when pageview_url='/shipping'              then 1 else 0 end) as shipping,
max(case when pageview_url= '/billing-2'              then 1 else 0 end) as billing,
max(case when pageview_url='/thank-you-for-your-order' then 1 else 0 end) as thanks
from website_pageviews wp
where wp.pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear','/cart','/shipping','/billing-2','/thank-you-for-your-order')
and wp.created_at between '2013-01-06' and '2013-04-10'
group by 1)k 
group by pageview_url
order by 2;











