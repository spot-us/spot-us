# == Schema Information
# Schema version: 20090218144012
#
# Table name: credits
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  amount      :decimal(15, 2)
#

class Credit < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :description, :amount
  
  # def self.total_credit(user)
  #     sum(:amount, :conditions => "user_id = #{user.id}")
  # end
  
  # def self.remaining_credit(user)
  #     allocated = CreditPitch.sum(:amount, :conditions => "user_id = #{user.id}")
  #     total_credit(user) - allocated
  # end
end

