SELECT orders.id, orders.id as order_id, orders.starts_on, orders.ends_on,
       COALESCE(sum(codes.limit_cents), 0) as order_total_limit,
       COALESCE(sum(codes.balance_cents), 0) as order_total_balance,
       COALESCE(count(members.id), 0) as order_total_members,
       COALESCE(count(codes.id), 0) as order_total_codes
  FROM orders
  INNER JOIN plans ON orders.plan_id = plans.id AND plans.deleted_at IS NULL
  INNER JOIN plan_product_categories ON plans.id = plan_product_categories.plan_id
  INNER JOIN codes ON plan_product_categories.id = codes.plan_product_category_id AND codes.deleted_at IS NULL
  INNER JOIN members ON codes.member_id = members.id AND members.deleted_at IS NULL
GROUP BY orders.id, orders.starts_on, orders.ends_on