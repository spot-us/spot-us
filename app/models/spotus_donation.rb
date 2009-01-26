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

end

# == Schema Information
# Schema version: 20090116200734
#
# Table name: spotus_donations
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  amount_in_cents :integer(4)
#  purchase_id     :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#

