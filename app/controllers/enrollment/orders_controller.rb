module Enrollment
  class OrdersController < DashboardController
    before_action :set_order, only: %i[edit update]
    layout :select_layout, only: %i[edit update]

    def edit
      params[:organization_id] = @order.organization.id
    end

    def update
      @order.attributes = permitted_params
      authorize @order
      params[:organization_id] = @order.organization.id
      if @order.save
        assign_redemption_instructions
        assign_special_offers
        respond_with @order, location: -> { navigation.next_path }
      else
        redirect_to edit_enrollment_order_path(@order, organization_id: @order.organization.id)
      end
    end

    protected
      def navigation
        Enrollment::Navigation.new new_organization_enrollment_sign_up_path(@order.organization), new_enrollment_order_member_path(@order)
      end

    private
      def set_order
        @order = Order.includes(:organization, :plan, plan_product_categories: { product_category: :price_points }).find params[:id]
        authorize @order
      end

      def permitted_params
        params
          .require(:order)
          .permit :starts_on, :ends_on,
                  plan_product_categories_attributes: %i[budget id usage_type]
      end

      def selected_redemption_instructions
        instructions = params.dig(:order, :plan_product_categories_attributes).values.collect { |value| { id: value.dig('redemption_instruction', 'instruction') } }
        instructions.reject { |i| i[:id].blank? }
      end

      def assign_redemption_instructions
        return if selected_redemption_instructions.none?

        selected_redemption_instructions.each do |redemption_instruction|
          new_instruction = RedemptionInstruction.find redemption_instruction[:id]
          new_instruction.update(active: true)
        end
      end

      def selected_special_offer
        if params['order']['special_offer_ids'].blank?
          SpecialOffer.none
        else
          SpecialOffer.where id: params['order']['special_offer_ids'].reject(&:blank?)
        end
      end

      def assign_special_offers
        return if @order.special_offers.any?

        selected_special_offer.each do |offer|
          @order.special_offers << offer
        end
      end

      def select_layout
        current_user.present? && current_user.orders.has_members.present? ? "dashboard" : "enrollment"
      end
  end
end
