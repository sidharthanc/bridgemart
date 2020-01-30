RSpec.describe Notification, type: :model do
  it { is_expected.to validate_presence_of(:sent_to) }
end
