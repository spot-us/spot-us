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
  has_one :donation
  belongs_to :cca
  belongs_to :pitch
  validates_presence_of :user_id, :description, :amount
end



