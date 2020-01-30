SELECT orders.id, orders.id as order_id, orders.starts_on, orders.ends_on,
       COALESCE(sum(codes.limit_cents), 0) as order_total_limit,
       COALESCE(sum(codes.balance_cents), 0) as order_total_balance,
       COALESCE(count(members.id), 0) as order_total_members,
       COALESCE(count(codes.id), 0) as order_total_codes
  FROM orders
  LEFT OUTER JOIN plans ON orders.plan_id = plans.id
  LEFT OUTER JOIN plan_product_categories ON plans.id = plan_product_categories.plan_id
  LEFT OUTER JOIN codes ON plan_product_categories.id = codes.plan_product_category_id
  LEFT OUTER JOIN members ON codes.member_id = members.id
GROUP BY orders.id, orders.starts_on, orders.ends_on