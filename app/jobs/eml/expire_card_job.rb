module EML
  class ExpireCardJob < ::ApplicationJob
    def perform(code)
      code.deactivate
      EML::LockCardJob.perform_now code, 'expired'
    end
  end
end
