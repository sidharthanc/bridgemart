class BackportUnloadedCentsDefaultOnCodes < ActiveRecord::Migration[5.2]
  def up
    say_with_time "Backport codes.unloaded_amount_cents default" do
      Code.unscoped.select(:id).find_in_batches.with_index do |batch, index|
        say("Processing batch #{index}\r", 0)
        Code.unscoped.where(id: batch).update_all(unloaded_amount_cents: 0)
      end
    end
  end
end
