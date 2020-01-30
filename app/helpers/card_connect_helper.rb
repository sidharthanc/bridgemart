require 'uri'

module CardConnectHelper
  CARD_CONNECT_IFRAME_PATH = '/itoke/ajax-tokenizer.html'.freeze
  def card_connect_iframe_src(propname)
    css = <<~'IFRAME_CSS'
      body{margin:0;padding:0;}
      input{border:1px solid %23ced4da;border-radius:4px;padding:0.375em 0.75em;font-size:16px;color:%23495057;line-height:1.5;}
      input%3Afocus{border-color:%2338f087;box-shadow:0 0 0 0.2em rgba(12, 156, 74, 0.25);}
      input%2Eerror{border-color:red;}
    IFRAME_CSS

    params = {}.tap do |params|
      params['tokenpropname'] = propname
      params['enhancedresponse'] = true
      params['formatinput'] = true
      params['unique'] = true
      params['css'] = css.strip
    end

    uri = URI(Rails.application.credentials.dig(Rails.env.to_sym, :cardconnect, :endpoint))
    uri.path = CARD_CONNECT_IFRAME_PATH
    # can't just use to_query here since that automatically passes the value through CGI.escape
    uri.query = params.collect do |key, value|
      [key, value].join('=')
    end.join('&')

    uri.to_s
  end
end
