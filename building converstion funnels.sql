create temporary table sub_table_ as 
select 
sub_table.website_session_id,
max(sub_table.product) as product_num,
max(sub_table.mr_fuzzy) as fuzzy_num,
max(sub_table.cart) as cart_num
from
(select 
ws.website_session_id,
wp.pageview_url,
wp.created_at, 
case when pageview_url = '/products' then 1 else 0 end as product, 
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mr_fuzzy, 
case when pageview_url = '/cart' then 1 else 0 end as cart
from website_sessions ws
left join website_pageviews wp
on ws.website_session_id = wp.website_session_id
where ws.created_at between '2014-01-01' and '2014-02-01' 
and wp.pageview_url in ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
order by 1,3) sub_table
group by sub_table.website_session_id;

select * from sub_table_;

select 
ws.website_session_id,
wp.pageview_url,
wp.created_at, 
case when pageview_url = '/products' then 1 else 0 end as product, 
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mr_fuzzy, 
case when pageview_url = '/cart' then 1 else 0 end as cart
from website_sessions ws
left join website_pageviews wp
on ws.website_session_id = wp.website_session_id
where ws.created_at between '2014-01-01' and '2014-02-01' 
and wp.pageview_url in ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
order by 1,3;







select 
count(website_session_id) as total_user,
count(case when product_num =1 then 1 else null end)/count(website_session_id) as products_clickthrough,
count(case when fuzzy_num =1 then 1 else null end)/count(case when product_num =1 then 1 else null end) as fuzzy_clcikthrough,
count(case when cart_num=1 then 1 else null end)/count(case when fuzzy_num =1 then 1 else null end) as payforit
from sub_table_;

select distinct pageview_url from website_pageviews;


-- one way to do it 
select 
sub.website_session_id,
sub.created_at,
sub.pageview_url,
case when sub.pageview_url = '/products' then 1 else 0 end as product,
case when sub.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as fuzzy,
case when sub.pageview_url = '/cart' then 1 else 0 end as cart,
case when sub.pageview_url = '/shipping' then 1 else 0 end as shipping,
case when sub.pageview_url = '/billing' then 1 else 0 end as billing,
case when sub.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_you
from
(select 
ws.website_session_id,
ws.created_at,
wp.pageview_url as pageview_url
from website_sessions ws
left join website_pageviews wp
on ws.website_session_id = wp.website_session_id
where ws.created_at between '2012-08-05' and '2012-09-05'
and wp.pageview_url in ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping', '/billing','/thank-you-for-your-order')
order by 1,2) sub;






-- the other way to do it 
create temporary table sub2 as 
select 
ws.website_session_id,
ws.created_at,
wp.pageview_url,
case when wp.pageview_url = '/products' then 1 else 0 end as product,
case when wp.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as fuzzy,
case when wp.pageview_url = '/cart' then 1 else 0 end as cart,
case when wp.pageview_url = '/shipping' then 1 else 0 end as shipping,
case when wp.pageview_url = '/billing' then 1 else 0 end as billing,
case when wp.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_you
from website_sessions ws
left join website_pageviews wp
on ws.website_session_id = wp.website_session_id
where ws.created_at between '2012-08-05' and '2012-09-05'
and wp.pageview_url in ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping', '/billing','/thank-you-for-your-order')
and ws.utm_source = 'gsearch'
and ws.utm_campaign = 'nonbrand'
order by 1,2;


select * from sub2;



create temporary table sub_num as
select 
website_session_id,
max(product) as num_product,
max(fuzzy) as num_fuzzy,
max(cart) as num_cart,
max(shipping) as num_shipping,
max(billing) as nun_billing,
max(thank_you) as num_thank_you
from sub2 
group by website_session_id;



select 
count(website_session_id) as total_user,
count(case when num_product=1 then 1 else null end) as make_to_product,
count(case when num_fuzzy=1 then 1 else null end) as make_to_fuzzy,
count(case when num_cart=1 then 1 else null end) as make_to_cart,
count(case when num_shipping =1 then 1 else null end ) as make_to_shipping,
count(case when nun_billing=1 then 1 else null end) as make_to_billing,
count(case when num_thank_you=1 then 1 else null end) as make_to_thanks
from sub_num;

select 
count(website_session_id) as total_user,
count(case when num_product=1 then 1 else null end)/count(website_session_id) as product_clickthrough,
count(case when num_fuzzy=1 then 1 else null end)/count(case when num_product=1 then 1 else null end) as fuzzy_click_through,
count(case when num_cart=1 then 1 else null end)/count(case when num_fuzzy=1 then 1 else null end) as cart_click_through,
count(case when num_shipping=1 then 1 else null end)/count(case when num_cart=1 then 1 else null end) as shipping_clickthrough,
count(case when nun_billing=1 then 1 else null end)/count(case when num_shipping=1 then 1 else null end) as billing_clickthrough,
count(case when num_thank_you=1 then 1 else null end)/count(case when nun_billing=1 then 1 else null end) as thanks
from sub_num;



select 
min(created_at) as first_created_at,
min(website_pageview_id) as first_pv_id
from website_pageviews
where pageview_url = '/billing-2'
group by pageview_url;


-- another way to know the date
select 
created_at,
pageview_url
from website_pageviews
where pageview_url = '/billing-2'
order by created_at;





select 
wp.pageview_url,
count(distinct wp.website_session_id) as sessions,
count(distinct orders.website_session_id) as orders,
count(distinct orders.website_session_id)/count(distinct wp.website_session_id) as converstion_rt
from website_pageviews wp
left join orders
on wp.website_session_id = orders.website_session_id
where wp.created_at between '2012-09-10 00:13:05' and '2012-11-10'
and wp.pageview_url in ('/billing', '/billing-2')
group by 1;


