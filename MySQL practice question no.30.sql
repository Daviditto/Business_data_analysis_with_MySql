##Given the transactions table below, write a query that finds the third purchase of every user.
##Note: Sort the results by the user_id in ascending order. If a user purchases two products at the same time, the lower id field is used to determine which is the first purchase.

select 
a.user_id, 
a.created_at,
a.product_id,
a.quantity
from 
(select 
*,
row_number() over(partition by ts.user_id order by ts.created_at) as rn
from transactions ts) a
where a.rn=3