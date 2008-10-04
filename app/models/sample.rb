# == Schema Information
#
# Table name: credentials
#
#  id          :integer(4)      not null, primary key
#  title       :string(255)     
#  url         :string(255)     
#  type        :string(255)     
#  description :text            
#  user_id     :integer(4)      
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Sample < Credential
end
