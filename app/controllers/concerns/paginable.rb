module Paginable
  extend ActiveSupport::Concern

  def paginate(collection)
    pagy(collection, page: params[:page])
  end
end
