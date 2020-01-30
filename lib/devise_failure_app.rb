class DeviseFailureApp < Devise::FailureApp
  def respond
    if json?
      render_error_json
    else
      super
    end
  end

  private
    def json?
      (request.format == :json) || (request.content_type == 'application/json')
    end

    def render_error_json
      self.status = 401
      self.content_type = request.format.to_s
      self.response_body = error_message.to_json
    end

    def error_message
      i18n_message(:invalid)
    end
end
