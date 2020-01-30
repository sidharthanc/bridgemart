SELECT organizations.id, count(orders.id) as total_orders, count(members.id) as total_members, 
  FROM organizations
    RIGHT OUTER JOIN plans  ON organizations.id = plans.organization_id
    RIGHT OUTER JOIN orders ON plans.id = orders.plan_id
    RIGHT OUTER JOIN members ON orders.id = members.order_id
  GROUP BY organizations.id

  