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
  
  named_scope :cca_credits, :conditions => 'cca_id is not null'
  
  validates_presence_of :user_id, :description, :amount

  def credit_amount
    amount
  end
  
  def self.users_with_unused_credits
    credits = self.find(:all,
      :select => "credits.*, SUM(credits.amount) as total_amount", 
      :joins => "LEFT JOIN donations ON donations.credit_id = credits.id LEFT JOIN spotus_donations ON spotus_donations.credit_id = credits.id", 
      :conditions => "donations.id is null and spotus_donations.id is null", :include => :user,
      :group => "credits.user_id having total_amount>0")
    return credits.map(&:user) if credits && !credits.empty?
    []
  end
end