class AddsDefaultValueToMemberCount < ActiveRecord::Migration[5.2]
  def change
    change_column_default :orders, :members_count, from: nil, to: 0
  end
end
