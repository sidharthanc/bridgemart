SELECT organizations.id, 
      count(orders.id) as total_orders,
      sum(member_counts.member_count) as total_members,
      sum(order_statistics.order_total_limit) AS total_load,
      sum(order_statistics.order_total_balance) AS total_balance,
      sum(order_statistics.order_total_codes) AS total_codes,
      organizations.id as organization_id
  FROM organizations
    INNER JOIN plans ON organizations.id = plans.organization_id
    INNER JOIN orders ON plans.id = orders.plan_id
    LEFT OUTER JOIN order_statistics ON orders.id = order_statistics.order_id -- order_statistics is a view
    LEFT OUTER JOIN (SELECT order_id, count(id) as member_count FROM members GROUP BY order_id) member_counts ON orders.id = member_counts.order_id
  GROUP BY organizations.id