-- final project:

select min(created_at), max(created_at) from website_sessions;


-- the overall sessions and orders volumn, trended by quarter for a business
select 
year(ws.created_at) as yr,
quarter(ws.created_at) as qrt,
count(ws.website_session_id) as sessions,
count(orders.website_session_id) as orders
from website_sessions ws
left join orders
on ws.website_session_id = orders.website_session_id
group by 1,2;

-- the quarterly figures of session_to_order rate, revenue per order, and revenue per session
select 
year(ws.created_at) as yr,
quarter(ws.created_at) as qrt,
count(ws.website_session_id) as sessions,
count(orders.website_session_id) as orders,
count(orders.website_session_id)/count(ws.website_session_id) as session_to_orders_rt,
sum(orders.price_usd)/count(orders.website_session_id) as rev_per_order,
sum(orders.price_usd)/count(ws.website_session_id) as rev_per_session
from website_sessions ws
left join orders
on ws.website_session_id = orders.website_session_id
group by 1,2;

-- quarterly view of orders from different channels 
select 
yr,
qrt,
max(case when channel_group='band_search' then orders else 0 end) as brand_search,
max(case when channel_group='direct_type_in' then orders else 0 end) as direct_type_in,
max(case when channel_group='organic_search' then orders else 0 end) as organic_search,
max(case when channel_group='gsearch_nonbrand' then orders else 0 end) as gsearch_nonbrand,
max(case when channel_group='bsearch_nonbrand' then orders else 0 end) as bsearch_nonbrand

from

(select 
year(ws.created_at) as yr,
quarter(ws.created_at) as qrt,
case 
when utm_source is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then 'organic_search'
when utm_source is null and http_referer is null then 'direct_type_in'
when utm_campaign = 'brand' then 'brand_search'
when utm_campaign = 'nonbrand' and utm_source='gsearch' then 'gsearch_nonbrand'
when utm_campaign = 'nonbrand' and utm_source='bsearch' then 'bsearch_nonbrand'
end as channel_group,
-- count(ws.website_session_id) as sessions,
count(orders.website_session_id) as orders
-- count(orders.website_session_id)/count(ws.website_session_id) as session_to_orders_rt
-- sum(orders.price_usd)/count(orders.website_session_id) as rev_per_order,
-- sum(orders.price_usd)/count(ws.website_session_id) as rev_per_session
from website_sessions ws
left join orders
on ws.website_session_id = orders.website_session_id
group by 1,2,3)k
group by yr,qrt;


-- overall session_to_order convertion rate trends for those channels, by quarterly

select 
yr,
qrt,
max(case when channel_group='brand_search' then session_to_orders_rt else 0 end) as brand_search,
max(case when channel_group='direct_type_in' then session_to_orders_rt else 0 end) as direct_type_in,
max(case when channel_group='organic_search' then session_to_orders_rt else 0 end) as organic_search,
max(case when channel_group='gsearch_nonbrand' then session_to_orders_rt else 0 end) as gsearch_nonbrand,
max(case when channel_group='bsearch_nonbrand' then session_to_orders_rt else 0 end) as bsearch_nonbrand

from

(select 
year(ws.created_at) as yr,
quarter(ws.created_at) as qrt,
case 
when utm_source is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then 'organic_search'
when utm_source is null and http_referer is null then 'direct_type_in'
when utm_campaign = 'brand' then 'brand_search'
when utm_campaign = 'nonbrand' and utm_source='gsearch' then 'gsearch_nonbrand'
when utm_campaign = 'nonbrand' and utm_source='bsearch' then 'bsearch_nonbrand' end as channel_group,
-- count(case when channel_group='band_search' then orders.website_session_id else null end) as brand_search,
-- count(case when channel_group='gsearch_nonbrand' then orders.website_session_id else null end) as gsearch_nonbrand,
-- count(case when channel_group='organic_search' then orders.website_session_id else null end) as organic_search,
-- count(case when channel_group='gsearch_nonbrand' then orders.website_session_id else null end) as gsearch_nonbrand,
-- count(case when channel_group='bsearch_nonbrand' then orders.website_session_id else null end) as bsearch_nonbrand
-- count(ws.website_session_id) as sessions,
-- count(orders.website_session_id) as orders
count(orders.website_session_id)/count(ws.website_session_id) as session_to_orders_rt
-- sum(orders.price_usd)/count(orders.website_session_id) as rev_per_order,
-- sum(orders.price_usd)/count(ws.website_session_id) as rev_per_session
from website_sessions ws
left join orders
on ws.website_session_id = orders.website_session_id
group by 1,2,3)k
group by yr,qrt;


-- monthly trending for revenue and margin by product, along with total sales and revenue

select
yr,
mo,
-- product_name,
sum(case when product_name='The Original Mr. Fuzzy' then price_usd else null end) as rev_fuzzy,
sum(case when product_name='The Forever Love Bear' then price_usd else null end) as rev_bear,
sum(case when product_name='The Birthday Sugar Panda' then price_usd else null end) as rev_panda,
sum(case when product_name='The Hudson River Mini bear' then price_usd else null end) as rev_hudson,

sum(case when product_name='The Original Mr. Fuzzy'then price_usd-cogs_usd else null end) as margin_fuzzy,
sum(case when product_name='The Forever Love Bear'  then price_usd-cogs_usd else null end) as margin_bear,
sum(case when product_name='The Birthday Sugar Panda' then price_usd-cogs_usd else null end) as margin_panda,
sum(case when product_name='The Hudson River Mini bear' then price_usd-cogs_usd else null end) as margin_hudson,
sum(price_usd) as total_rev,
sum(price_usd-cogs_usd)total_margin
from
(select 
year(orders.created_at) as yr,
month(orders.created_at) as mo,
-- order_items.product_id,
k.product_name,
-- sum(orders.price_usd)/count(k.product_name) as rev_by_product,
-- sum(orders.price_usd-orders.cogs_usd)/count(k.product_name) as margin_by_product,
orders.order_id,
orders.price_usd,
orders.cogs_usd
from orders
left join 
(select 
order_items.order_id,
order_items.product_id,
products.product_name
from order_items
left join products
on order_items.product_id = products.product_id)k
on orders.order_id = k.order_id)j
group by 1,2;


select 
year(orders.created_at) as yr,
month(orders.created_at) as mo,
-- order_items.product_id,
k.product_name,
-- sum(orders.price_usd)/count(k.product_name) as rev_by_product,
-- sum(orders.price_usd-orders.cogs_usd)/count(k.product_name) as margin_by_product,
orders.order_id,
orders.price_usd,
orders.cogs_usd
from orders
left join 
(select 
order_items.order_id,
order_items.product_id,
products.product_name
from order_items
left join products
on order_items.product_id = products.product_id)k
on orders.order_id = k.order_id;


-- monthly sessions to the /products page, and how the % of those sessions click through another page, along with 
-- a view how conversion from /products to placing an order has improved
create temporary table session_seeing_product as
select
created_at,
website_session_id,
website_pageview_id
from website_pageviews
where pageview_url ='/products';


create temporary table session_click_to_another_page as
select
ws.created_at,
ws.website_session_id,
ws.website_pageview_id
from session_seeing_product ssp
left join website_pageviews ws
on ssp.website_session_id = ws.website_session_id
and ws.website_pageview_id > ssp.website_pageview_id
group by ssp.website_session_id
having min(ws.website_pageview_id) is not null;


select 
year(session_seeing_product.created_at) as yr,
month(session_seeing_product.created_at) as mo,
count(session_seeing_product.website_session_id) as sessions,
count(session_click_to_another_page.website_session_id) as click_thru,
count(session_click_to_another_page.website_session_id)/count(session_seeing_product.website_session_id) as pct_click_thru,
count(orders.website_session_id) as orders,
count(orders.website_session_id)/count(session_seeing_product.website_session_id) as convt_rt
from session_seeing_product 
left join session_click_to_another_page
on session_seeing_product.website_session_id = session_click_to_another_page.website_session_id
left join orders
on session_seeing_product.website_session_id = orders.website_session_id
group by 1,2;


-- sals data since the launch the 4th primary product on DEC.05, 2014, and how well each prodcut cross sell with each other
select
primary_product_id,
count(id) as total_,
count(case when product_id = 1 then product_id else null end) as cross_sell_with_product_1,
count(case when product_id = 2 then product_id else null end) as cross_sell_with_product_2,
count(case when product_id = 3 then product_id else null end) as cross_sell_with_product_3,
count(case when product_id = 4 then product_id else null end) as cross_sell_with_product_4,

count(case when product_id = 1 then product_id else null end)/sum(primary_product_id) as cross_sell_with_product_1_rt,
count(case when product_id = 2 then product_id else null end)/sum(primary_product_id) as cross_sell_with_product_2_rt,
count(case when product_id = 3 then product_id else null end)/sum(primary_product_id) as cross_sell_with_product_3_rt,
count(case when product_id = 4 then product_id else null end)/sum(primary_product_id) as cross_sell_with_product_4_rt
from
(select 
orders.created_at,
orders.order_id as id,
orders.primary_product_id,
order_items.order_id,
order_items.product_id,
order_items.is_primary_item
from orders
left join order_items
on orders.order_id = order_items.order_id
where orders.created_at > '2014-12-05') l
where is_primary_item = 0
group by 1
order by 1;


select 
f.primary_product_id,
f.total_order,
b.cross_sell_with_product_1,
b.cross_sell_with_product_2,
b.cross_sell_with_product_3,
b.cross_sell_with_product_4,
b.cross_sell_with_product_1/f.total_order as cross_sell_with_product_1_rt,
b.cross_sell_with_product_2/f.total_order as cross_sell_with_product_2_rt,
b.cross_sell_with_product_3/f.total_order as cross_sell_with_product_3_rt,
b.cross_sell_with_product_4/f.total_order as cross_sell_with_product_4_rt
from
(select
primary_product_id,
count(order_id) as total_order
from orders
where orders.created_at > '2014-12-05'
group by primary_product_id) f
left join

(select
primary_product_id,
count(case when product_id = 1 then product_id else null end) as cross_sell_with_product_1,
count(case when product_id = 2 then product_id else null end) as cross_sell_with_product_2,
count(case when product_id = 3 then product_id else null end) as cross_sell_with_product_3,
count(case when product_id = 4 then product_id else null end) as cross_sell_with_product_4,

count(case when product_id = 1 then product_id else null end)/sum(primary_product_id) as cross_sell_with_product_1_rt,
count(case when product_id = 2 then product_id else null end)/sum(primary_product_id) as cross_sell_with_product_2_rt,
count(case when product_id = 3 then product_id else null end)/sum(primary_product_id) as cross_sell_with_product_3_rt,
count(case when product_id = 4 then product_id else null end)/sum(primary_product_id) as cross_sell_with_product_4_rt
from
(select 
orders.created_at,
orders.order_id as id,
orders.primary_product_id,
order_items.order_id,
order_items.product_id,
order_items.is_primary_item
from orders
left join order_items
on orders.order_id = order_items.order_id
where orders.created_at > '2014-12-05') l
where is_primary_item = 0
group by 1
order by 1) b
on f.primary_product_id = b.primary_product_id
order by 1;



select
primary_product_id,
count(order_id) as total_order
from orders
where orders.created_at > '2014-12-05'
group by primary_product_id;

select * from orders;