module OauthConnect
  def oauth_client
		OAuth2::Client.new(FACEBOOK_CONSUMER_KEY, FACEBOOK_CONSUMER_SECRET, :site => 'https://graph.facebook.com')
	end
	
	def append_port(default_host)
	  default_host << ":3000" if default_host == "spotus.local"
	  default_host
  end
	  
  def fb_access_token(code)
	  oauth_client.web_server.get_access_token(code, :redirect_uri => "http://" + append_port(APP_CONFIG[:default_host]) + "/auth/facebook/callback") # | redirect_uri(uri)
  end

  def redirect_uri(uri)
    uri = URI.parse(uri)
    uri.path = '/auth/facebook/callback'
    uri.query = nil
    uri.to_s
  end

	
end