# == Schema Information
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  email                     :string(255)     
#  crypted_password          :string(40)      
#  salt                      :string(40)      
#  created_at                :datetime        
#  updated_at                :datetime        
#  remember_token            :string(255)     
#  remember_token_expires_at :datetime        
#  first_name                :string(255)     
#  last_name                 :string(255)     
#  type                      :string(255)     
#  photo_file_name           :string(255)     
#  photo_content_type        :string(255)     
#  photo_file_size           :integer(4)      
#  location                  :string(255)     
#  about_you                 :text            
#  website                   :string(255)     
#

class Organization < User
end
