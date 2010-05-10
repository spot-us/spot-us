module OauthConnect
  def oauth_client
		OAuth2::Client.new(FACEBOOK_CONSUMER_KEY, FACEBOOK_CONSUMER_SECRET, :site => 'https://graph.facebook.com')
	end
	
	def check_is_dev(default_host)
	  return "spotus.local:3000" if Rails.env.development?
	  default_host
  end
	  
  def fb_access_token(code)
    begin
	    oauth_client.web_server.get_access_token(code, :redirect_uri => "http://" + check_is_dev(APP_CONFIG[:default_host]) + "/auth/facebook/callback") # | redirect_uri(uri)
    rescue 
      return false
    end
  end

  def redirect_uri
    "http://" + check_is_dev(APP_CONFIG[:default_host]) + "/auth/facebook/callback"
    # uri = URI.parse(uri)
    # uri.path = '/auth/facebook/callback'
    # uri.query = nil
    # uri.to_s
  end

	
end