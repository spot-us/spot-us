class SpotusDonation < ActiveRecord::Base
  belongs_to :user
  belongs_to :purchase

  validates_presence_of :amount_in_cents

  named_scope :unpaid, :conditions => { :purchase_id => nil }, :limit => 1

  SPOTUS_TITHE = 0.10

  def amount_in_cents
    return self[:amount_in_cents] unless self[:amount_in_cents].blank?
    tithe
  end

  def amount_in_dollars
    amount_in_cents.to_dollars
  end

  def amount_in_dollars=(val)
    self[:amount_in_cents] = val.to_cents
  end

  def tithe
    (user.unpaid_donations_sum_in_cents * SPOTUS_TITHE).to_dollars.to_f.round.to_cents
  end

end
