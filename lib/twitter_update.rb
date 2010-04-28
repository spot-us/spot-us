#hold class until the next step

class TwitterUpdate

  def self.update_status?(status)
    if APP_CONFIG[:twitter]
      begin
        client = Twitter::Client.new(:login => APP_CONFIG[:twitter][:login], :password => APP_CONFIG[:twitter][:password])
        obj = update_status(client, status)
      rescue Twitter::RESTError => re 
        logger.info("REST ERROR: Automatic Twitter Update for #{headline} failed")
      rescue Twitter::Error
        logger.info("ERROR: Automatic Twitter Update for #{headline} failed")
      end
    end
  end

  def self.update_status(client, status)
    request_status = nil
    begin
      request_status = client.status(:post, status)
    rescue Twitter::RESTError => re 
      logger.info(re.inspect)
    rescue Twitter::Error
    end
    return request_status
  end
  
end
