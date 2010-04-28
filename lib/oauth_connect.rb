module OauthConnect
  def oauth_client
		OAuth2::Client.new(FACEBOOK_CONSUMER_KEY, FACEBOOK_CONSUMER_SECRET, :site => 'https://graph.facebook.com')
	end
	  
  def fb_access_token(code, uri)
	  oauth_client.web_server.get_access_token(code, :redirect_uri => redirect_uri(uri))
  end

  def redirect_uri(uri)
		uri = URI.parse(uri)
		uri.path = '/auth/facebook/callback'
		uri.query = nil
		uri.to_s
	end
	
	def fb_wall_publish(access_token, post)
	  return false if post[:message].blank?
	  query_string = ""
	  query_string << "message=" + post[:message] if post[:message]
	  query_string << "&description=" + post[:description] if post[:description]
	  query_string << "&link=" + post[:link] if post[:link]
	  query_string << "&picture=" + post[:picture] if post[:picture]
	  query_string << "&name=" + post[:name] if post[:name]
	  access_token.post('/me/feed?' + query_string)
  end
	
end