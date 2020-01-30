module Enrollment
  class BrokersController < Enrollment::BaseController
    include SignUpable

    def new
      @broker = Broker.new
    end

    def create
      @broker = Broker.new permitted_params
      sign_in_and_invite_user(@broker) if @broker.save
      respond_with @broker, location: new_enrollment_sign_up_path
    end

    private
      def permitted_params
        params.require(:broker).permit(:first_name, :last_name, :email, :phone, :broker_organization_name)
      end
  end
end
