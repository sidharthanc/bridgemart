require 'csv'

module Enrollment
  class MemberImportJob < ::ApplicationJob
    queue_as :high # only high because it is usually called from the enrollment process
    include WithProblems

    HEADERS = %w[FirstName MiddleName LastName Email Street City State Zip ExternalMemberId].freeze

    def perform(member_import)
      i = 0
      problems = []
      members = []

      CSV.parse(member_import.file.download, headers: true) do |row|
        i += 1
        member = ::Member.new member_params_from_row(row)
        member.address = Address.new address_params_from_row(row)
        member.order = member_import.order

        problems << problems_for(member, index: i) unless member.valid?
        members << member
      end

      member_import.update problems: problems
      begin
        Member.transaction { members.map(&:save!) }
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Error in during Member Import Process-- Exception: #{e}"
      end
    end

    private
      def member_params_from_row(row)
        {
          first_name: row['FirstName'],
          middle_name: row['MiddleName'],
          last_name: row['LastName'],
          email: row['Email'],
          external_member_id: row['ExternalMemberId']
        }
      end

      def address_params_from_row(row)
        {
          street1: row['Street'],
          city: row['City'],
          state: row['State'],
          zip: row['Zip']
        }
      end
  end
end
