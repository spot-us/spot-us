# == Schema Information
#
# Table name: pledges
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)      
#  tip_id          :integer(4)      
#  amount_in_cents :integer(4)      
#  created_at      :datetime        
#  updated_at      :datetime        
#

class Pledge < ActiveRecord::Base
  belongs_to :user
  belongs_to :tip
  validates_presence_of :tip_id
  validates_presence_of :user_id
  validates_presence_of :amount

  has_dollar_field(:amount)
end

