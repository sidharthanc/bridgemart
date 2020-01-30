module Orders
  class GenerateCodes
    def self.execute(order)
      order.with_lock do
        return false unless order.generated_at.blank? && order.paid?

        order.touch(:generated_at)
      end
      order.with_lock do
        order.members.each do |member|
          order.plan_product_categories.each do |ppc|
            next if member.codes.where(plan_product_category: ppc, member_id: member.id).exists?

            member.codes.create! limit: ppc.budget, plan_product_category: ppc, virtual_card_provider: ppc.product_category.card_type.to_sym, starts_on: order.starts_on, expires_on: order.ends_on
          end
          CodeMailer.registered_email(member).deliver_later # TODO: wisper this
        end
      end
      order.update_code_delivery # TODO: this should get set from the mailer
      order.started!
    end
  end
end
