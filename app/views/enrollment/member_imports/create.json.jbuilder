json.member_import do
  json.order_id @member_import.order_id
  json.acknowledged @member_import.acknowledged
  json.updated_at @member_import.updated_at
  json.created_at @member_import.created_at
  json.problems @member_import.problems
  json.id @member_import.id
end
