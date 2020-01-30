RSpec.describe Orders::DeletePendingOrdersJob, type: :job do
  let!(:fresh_pending_order) { create(:order, created_at: 29.days.ago, is_cancelled: false) }
  let!(:old_pending_order) { create(:order, created_at: 31.days.ago, is_cancelled: false) }
  let!(:fresh_processed_order) { create(:order, created_at: 29.days.ago, is_cancelled: false, processed_at: 28.days.ago, paid: true) }
  let!(:old_processed_order) { create(:order, created_at: 31.days.ago, is_cancelled: false, processed_at: 30.days.ago, paid: true) }

  it 'marks an out-of-date, pending order as deleted' do
    subject.perform
    expect(old_pending_order.reload.deleted_at).to be_present
  end

  it 'does not mark an out-of-date, processed order as deleted' do
    subject.perform
    expect(old_processed_order.reload.deleted_at).not_to be_present
  end

  it 'does not mark a pending order less than 30 days old as deleted' do
    subject.perform
    expect(fresh_pending_order.reload.deleted_at).not_to be_present
  end

  it 'does not mark a processed order less than 30 days old as deleted' do
    subject.perform
    expect(fresh_processed_order.reload.deleted_at).not_to be_present
  end
end
