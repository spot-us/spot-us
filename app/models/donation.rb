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
  validates_numericality_of :amount_in_cents, :greater_than => 0
  validate_on_update :disable_updating_paid_donations, :check_donation, :if => lambda { |me| me.pitch }
  validate_on_create :check_donation, :if => lambda { |me| me.pitch }

  named_scope :unpaid, :conditions => "not paid"
  named_scope :paid, :conditions => "paid"
  
  has_dollar_field(:amount)

  def self.createable_by?(user)
    user
  end

  def editable_by?(user)
    self.user == user
  end

  protected

  def disable_updating_paid_donations
    if paid? && !being_marked_as_paid?
      errors.add_to_base('Paid donations cannot be updated')
    end
  end

  def being_marked_as_paid?
    paid_changed? && !paid_was
  end
    
  def check_donation
    if pitch.fully_funded?
      errors.add_to_base("Great news! This pitch is already fully funded therefore it can't be donated to any longer.")
      return
    end
    
    unless pitch.user_can_donate_more?(user, amount_in_cents)
      errors.add_to_base("Thanks for your support but we only allow donations of 20% of requested amount from one user. Please lower your donation amount and try again.")
    end
  end
end
