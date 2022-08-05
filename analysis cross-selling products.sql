-- pre-assignment exercise 

select
count(orders.order_id),
orders.primary_product_id,
order_items.product_id
from orders
left join order_items
on orders.order_id = order_items.order_id
and order_items.is_primary_item = 0 
where orders.order_id between 10000 and 11000
group by 2,3
order by 2,3;

select
orders.primary_product_id,
count(case when product_id =1 then orders.order_id else null end) as one_cross,
count(case when product_id =2 then orders.order_id else null end) as two_cross,
count(case when product_id =3 then orders.order_id else null end) as three_cross,
count(orders.order_id)
from orders
left join order_items
on orders.order_id = order_items.order_id
and order_items.is_primary_item = 0 
where orders.order_id between 10000 and 11000
group by 1;


select
orders.primary_product_id,
count(case when product_id =1 then orders.order_id else null end)/count(orders.order_id) as one_cross_rt,
count(case when product_id =2 then orders.order_id else null end)/count(orders.order_id) as two_cross_rt,
count(case when product_id =3 then orders.order_id else null end)/count(orders.order_id) as three_cross_rt,
count(orders.order_id)
from orders
left join order_items
on orders.order_id = order_items.order_id
and order_items.is_primary_item = 0 
where orders.order_id between 10000 and 11000
group by 1
order by 1;






-- assignment 1:
-- session_seeing_cart:
create temporary table session_seeing_cart as 
select 
case when created_at < '2013-09-25' then 'pre-cross-cell'
when created_at >= '2013-01-06' then 'post-cross-cell' end as time_peroid,
website_session_id,
website_pageview_id # important one
from website_pageviews 
where pageview_url = '/cart'
and created_at between '2013-08-25' and '2013-10-25';


create temporary table session_seeing_another_page as
select
session_seeing_cart.time_peroid,
session_seeing_cart.website_session_id,
min(wp.website_pageview_id) as next_pv_id_after_cart
from session_seeing_cart
left join website_pageviews wp
on session_seeing_cart.website_session_id= wp.website_session_id
and wp.website_pageview_id > session_seeing_cart.website_pageview_id
group by session_seeing_cart.time_peroid, session_seeing_cart.website_session_id
having min(wp.website_pageview_id) is not null;


create temporary table post_session_orders as
select 
time_peroid,
ssc.website_session_id,
order_id,
items_purchased,
price_usd
from session_seeing_cart ssc
inner join orders
on ssc.website_session_id = orders.website_session_id;




select 
time_peroid,
count(website_session_id),
sum(click_thru) as click_thru,
sum(click_thru) /count(website_session_id) as cart_cvt_rt,
sum(placed_order) as sum_of_orders,
count(items_purchased) as product_purchased,
count(items_purchased)/sum(placed_order) as item_per_order,
sum(price_usd) as rev,
sum(price_usd)/sum(placed_order)  as aov,
sum(price_usd)/count(distinct website_session_id) rev_per_session
from  
(select 
session_seeing_cart.time_peroid,
session_seeing_cart.website_session_id,
case when session_seeing_another_page.website_session_id is null then 0 else 1 end as click_thru,
case when post_session_orders.order_id is null then 0 else 1 end as placed_order,
post_session_orders.items_purchased,
post_session_orders.price_usd
from session_seeing_cart
left join session_seeing_another_page
on session_seeing_cart.website_session_id = session_seeing_another_page.website_session_id
left join post_session_orders
on session_seeing_cart.website_session_id = post_session_orders.website_session_id
group by website_session_id) k
group by time_peroid;

-- assignment 2:




select 
time_peroid,
count(distinct sessions) as sessions,
count(distinct orders) as orders,
count(distinct orders)/count(distinct sessions) as cvt_rt,
count(items_purchased) as purchased,
count(items_purchased)/count(distinct orders) product_per_order,
sum(price_usd)/count(distinct orders) as aov,
sum(price_usd) as rev,
sum(price_usd)/count(distinct sessions) as rev_per_sec
from
(select
case when ws.created_at< '2013-12-12' then 'pre' 
when ws.created_at > '2013-12-12' then 'pos' end as time_peroid,
ws.website_session_id as sessions,
orders.order_id as orders,
orders.items_purchased,
orders.price_usd
from website_sessions ws
left join orders
on ws.website_session_id = orders.website_session_id
where ws.created_at between '2013-11-12 ' and '2014-01-12')k
group by time_peroid



