module Enrollment
  class MemberImportsController < ApplicationController
    respond_to :json

    before_action :set_order, only: :create

    def create
      @member_import = MemberImport.new permitted_params
      @member_import.order = @order
      @member_import.start_import if @member_import.save
      respond_with @member_import
    end

    def show
      @member_import = MemberImport.find(params[:id])
      respond_with @member_import
    end

    private
      def set_order
        @order = Order.find params[:order_id]
      end

      def permitted_params
        params.permit :file
      end
  end
end
