# == Schema Information
#
# Table name: credits
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)      
#  description     :string(255)     
#  amount_in_cents :integer(4)      
#  created_at      :datetime        
#  updated_at      :datetime        
#

class Credit < ActiveRecord::Base
  belongs_to :user
  has_dollar_field :amount
  
  validates_presence_of :user_id, :description, :amount
end
