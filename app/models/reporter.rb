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
#  address1                  :string(255)     
#  address2                  :string(255)     
#  city                      :string(255)     
#  state                     :string(255)     
#  zip                       :string(255)     
#  phone                     :string(255)     
#  country                   :string(255)     
#  notify_tips               :boolean(1)      not null
#  notify_pitches            :boolean(1)      not null
#  notify_stories            :boolean(1)      not null
#  notify_spotus_news        :boolean(1)      not null
#  fact_check_interest       :boolean(1)      not null
#  status                    :string(255)     default("active")
#  organization_name         :string(255)     
#  established_year          :string(255)     
#

class Reporter < User
end
