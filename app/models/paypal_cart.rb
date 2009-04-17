class PaypalCart < ActiveRecord::Base
  belongs_to :user
  has_many :donations
  has_one :spotus_donation
  validates_presence_of :user

  def self.create_from_purchase(purchase)
    PaypalCart.create(:user => purchase.user, :spotus_donation => purchase.spotus_donation, :donations => purchase.donations)
  end
end
