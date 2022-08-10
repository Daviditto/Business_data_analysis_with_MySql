select 
order_items.order_id,
order_items.order_item_id,
order_items.created_at,
order_items.price_usd,
order_item_refunds.order_item_id,
order_item_refunds.created_at,
order_item_refunds.refund_amount_usd
from order_items
left join order_item_refunds
on order_items.order_id = order_item_refunds.order_id
where order_items.order_id in (3489,31049,27061);


-- analysis of product refund rate

select 
year(it.created_at) as yr,
month(it.created_at) as mo,
count(case when it.product_id=1 then it.order_item_id else null end) as p1_orders,
count(case when it.product_id=1 then rf.order_item_id else null end)/count(case when it.product_id=1 then it.order_item_id else null end) as p1_return_rt,
count(case when it.product_id=2 then it.order_item_id else null end) as p2_orders,
count(case when it.product_id=2 then rf.order_item_id else null end) /count(case when it.product_id=2 then it.order_item_id else null end)  as p2_return_rt,
count(case when it.product_id=3 then it.order_item_id else null end) as p3_orders,
count(case when it.product_id=3 then rf.order_item_id else null end)/ count(case when it.product_id=3 then it.order_item_id else null end) as p3_return_rt,
count(case when it.product_id=4 then it.order_item_id else null end) as p3_orders,
count(case when it.product_id=4 then rf.order_item_id else null end)/ count(case when it.product_id=4 then it.order_item_id else null end) as p4_return_rt
-- it.order_id,
-- it.order_item_id as orders,
-- rf.order_item_id as refund
from order_items it
left join order_item_refunds rf
on it.order_id = rf.order_id
where it.created_at < '2014-10-15'
group by year(created_at), month(created_at);



select * from order_item_refunds;