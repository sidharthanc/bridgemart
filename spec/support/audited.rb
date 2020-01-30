RSpec::Matchers.define :be_auditable do
  match do |object|
    object.respond_to? :audits
  end

  failure_message do |object|
    "expected #{object.class} to respond to #audits"
  end
end
