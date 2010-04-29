require 'twitter'
 
class TwitterCredential < ActiveRecord::Base
    
  belongs_to :user
  validates_uniqueness_of :user_name, :on => :create, :message => "The username is already taken"
  validates_presence_of :user_name, :on => :create, :message => "The username cannot be blank"
  validates_presence_of :password, :on => :create, :message => "Password cannot be blank"
  validates_presence_of :user_id, :on => :create, :message => "User id cannot be blank"
  
  def update?(msg, options)
    update_status_msg(user, msg, options)
  end
    
  def update_status_msg(user, status, options={})  
    obj = nil
    
    unless UPDATE_TWITTER
      begin
        client = get_client(user, option)
        obj = update_status(client, status)
      rescue Twitter::RESTError => re 
        return raise_error?('REST ERROR', status)
      rescue Twitter::Error
        return raise_error?('ERROR', status)
      end
    else
      #get the user and email update
      obj = Mailer.deliver_notification_email(MAIL_WEBMASTER, "Update of Twitter for #{user.user_name} with email #{user.email}","Test Twitter update with this status: #{status}") if user
    end               
    
    obj
  end
  
  def check_connection?
    begin
      client = get_client(user, option)
      status = client.timeline_for(:me)
      return true
    rescue Twitter::RESTError => re 
      return raise_error?('REST ERROR')
    rescue Twitter::Error
      return raise_error?
    end
    return false
  end
  
  def raise_error?(type='ERROR', status='')
    Mailer.deliver_notification_email(MAIL_WEBMASTER, "Update of Twitter for #{user.user_name} with email #{user.email}", "Attempted Twitter update with this status: #{status}") if user
    logger.info("#{type}: Update of Twitter for #{user.user_name} with email #{user.email}")
    return false
  end
  
  def get_client(user, option)
    unless user && (!options[:user_name] || options[:password])
      return Twitter::Client.new(:login => user_name,:password => password)
    else
      return Twitter::Client.new(:login => options[:user_name],:password => options[:password])
    end
  end
  
  #updates twitter
  def update_status(client, status)
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