# == Schema Information
# Schema version: 20090218144012
#
# Table name: spotus_donations
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  purchase_id :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#  amount      :decimal(15, 2)
#

class SpotusDonation < ActiveRecord::Base
  belongs_to :user
  belongs_to :purchase

  validates_presence_of :amount

  named_scope :unpaid, :conditions => { :purchase_id => nil }, :limit => 1
  named_scope :paid, :conditions => 'purchase_id IS NOT NULL'

  SPOTUS_TITHE = 0.10

  def amount
    return self[:amount] unless self[:amount].blank?
    tithe
  end

  def tithe
    (user.unpaid_donations_sum * SPOTUS_TITHE).round
  end

  def self.find_from_paypal(paypal_params)
    spotus_donation = if spotus_keys = paypal_params.detect{|k,v| v =~ /support spot\.us/i}
      spotus_donation_id = paypal_params.delete(spotus_keys.first.gsub(/name/, 'number'))
      SpotusDonation.find(spotus_donation_id)
    end
  end
end

