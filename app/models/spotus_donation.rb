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
  belongs_to :credit
  
  validates_presence_of :amount

  named_scope :unpaid, :conditions => "(purchase_id is null and credit_id is null) OR 
        (credit_id is not null and spotus_donations.amount>ABS(credits.amount)) OR 
        (purchase_id is not null and spotus_donations.amount>purchases.total_amount) OR 
        (credit_id is not null and purchase_id is not null and spotus_donations.amount>(purchases.total_amount+ABS(credits.amount)))", 
      :joins=>"left join credits on credits.id=credit_id left join purchases on purchases.id=purchase_id", 
      :limit => 1
      
  named_scope :paid, :conditions => "(credit_id is not null and spotus_donations.amount<=ABS(credits.amount)) OR 
          (purchase_id is not null and spotus_donations.amount<=purchases.total_amount) OR 
          (credit_id is not null and purchase_id is not null and spotus_donations.amount<=(purchases.total_amount+ABS(credits.amount)))", 
      :joins=>"left join credits on credits.id=credit_id left join purchases on purchases.id=purchase_id"

  SPOTUS_TITHE = 0.1

  def amount
    return self[:amount] unless self[:amount].blank?
    tithe
  end

  def tithe
    (user.unpaid_donations_sum * SPOTUS_TITHE).round
  end
 
  def unpaid?
    (purchase.blank? && credit.blank?) || (!credit.blank? && credit.amount.abs<amount) || (!purchase.blank? && purchase.total_amount<amount) || (!credit.blank? && !purchase.blank? && (credit.amount.abs+purchase.total_amount)<amount)
  end
  
  def paid?
    !unpaid?
  end

  def self.find_from_paypal(paypal_params)
    spotus_donation = if spotus_keys = paypal_params.detect{|k,v| v =~ /support spot\.us/i}
      spotus_donation_id = paypal_params.delete(spotus_keys.first.gsub(/name/, 'number'))
      SpotusDonation.find(spotus_donation_id)
    end
  end
end

