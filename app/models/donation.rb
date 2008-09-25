# == Schema Information
#
# Table name: donations
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)      
#  pitch_id        :integer(4)      
#  created_at      :datetime        
#  updated_at      :datetime        
#  amount_in_cents :integer(4)      
#  paid            :boolean(1)      not null
#  purchase_id     :integer(4)      
#

class Donation < ActiveRecord::Base
  belongs_to :user
  belongs_to :pitch
  belongs_to :purchase
  validates_presence_of :pitch_id
  validates_presence_of :user_id
  validates_presence_of :amount

  named_scope :unpaid, :conditions => "not paid"
  has_dollar_field(:amount)
end

