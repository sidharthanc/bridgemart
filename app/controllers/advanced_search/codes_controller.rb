module AdvancedSearch
  class CodesController < ::DashboardController
    def new
      @member = Member.find params[:member_id]
      @codes = @member.sorted_codes
      @search = @codes.ransack(params[:q])
    end
  end
end
