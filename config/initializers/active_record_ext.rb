class ActiveRecord::Base
  # given a hash of attributes including the ID, look up the record by ID. 
  # If it does not exist, it is created with the rest of the options. 
  # If it exists, it is updated with the given options. 
  #
  # Raises an exception if the record is invalid to ensure seed data is loaded correctly.
  # 
  # Returns the record.
  #
  # http://railspikes.com/2008/2/1/loading-seed-data
  
  def self.create_or_update(options = {})
    id = options.delete(:id)
    record = find_by_id(id) || new
    record.id = id
    
    # we have to override any attribute protections by going to 'send' directly
    options.each { |k, v| record.send("#{k}=", v) }
    
    record.save!
    record
  end
  
  def self.create_or_update_by_email(options = {})
    email = options.delete(:email)
    record = find_by_email(email) || new
    record.email = email
    
    # we have to override any attribute protections by going to 'send' directly
    options.each { |k, v| record.send("#{k}=", v) }
    
    record.save!
    record    
  end
end
