class Donation < ActiveRecord::Base
  belongs_to :user
  belongs_to :pitch
  belongs_to :purchase
  validates_presence_of :pitch_id
  validates_presence_of :user_id
  validates_presence_of :amount_in_cents

  named_scope :unpaid, :conditions => "not paid"
end

