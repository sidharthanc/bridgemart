class MemberExport
  def initialize(members, organization)
    @members = members
    @organization = organization
  end

  def filename
    "members-#{Date.current}"
  end

  def csv
    CSV.generate(headers: true) do |csv|
      csv << column_headers
      @members.each do |member|
        if member.codes.present?
          member.codes.each do |code|
            csv << member_and_code(member, code)
          end
        else
          csv << member_and_no_code(member)
        end
      end
    end
  end

  private
    def member_and_code(member, code)
      [
        @organization.id,
        member.id,
        member.name,
        member.phone,
        member.email,
        member.order_id,
        code.id,
        code.limit,
        code.deactivated_at,
        code.created_at,
        code.card_number,
        code.product_category&.id,
        code.balance_cents
      ]
    end

    def member_and_no_code(member)
      member_and_code(member, Code.new)
    end

    def column_headers
      headers = %w[organization_id id name phone email order_id code_id limit deactivated_at created_at external_id product_category_id balance_cents]

      headers.map do |col|
        I18n.t("members.index.columns.#{col}")
      end
    end
end
