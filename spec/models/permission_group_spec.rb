RSpec.describe PermissionGroup, type: :model do
  it { is_expected.to have_and_belong_to_many(:users) }
end
