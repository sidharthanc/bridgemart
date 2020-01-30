# This is a patch so Capybara/Cucumber can share database connectiojns, allowing
# the use of transactions in Capybara
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil
  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(size: 1) { retrieve_connection }
  end
end

ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
