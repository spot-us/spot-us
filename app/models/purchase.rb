# == Schema Information
#
# Table name: purchases
#
#  id                        :integer(4)      not null, primary key
#  first_name                :string(255)
#  last_name                 :string(255)
#  credit_card_number_ending :string(255)
#  address1                  :string(255)
#  address2                  :string(255)
#  city                      :string(255)
#  state                     :string(255)
#  zip                       :string(255)
#  user_id                   :integer(4)
#  total_amount_in_cents     :integer(4)
#  created_at                :datetime
#  updated_at                :datetime
#

require 'lib/dollars'
class Purchase < ActiveRecord::Base
  class GatewayError < RuntimeError; end

  attr_accessor :credit_card_number, :credit_card_year, :credit_card_month,
    :credit_card_type, :verification_value
  attr_reader :credit_card

  cattr_accessor :gateway

  after_create :associate_donations, :apply_credits, :associate_spotus_donations
  before_create :bill_credit_card
  before_validation_on_create :build_credit_card, :set_credit_card_number_ending, :set_total_amount_in_cents
  validates_presence_of :first_name, :last_name, :credit_card_number_ending,
    :address1, :city, :state, :zip, :user_id, :unless => lambda {|p| p.credit_covers_total? }

  validates_presence_of :credit_card_number, :credit_card_year,
    :credit_card_type, :credit_card_month, :verification_value,
    :on => :create, :unless => lambda {|p| p.credit_covers_total? }

  validate :validate_credit_card, :on => :create, :unless => lambda {|p| p.credit_covers_total? }

  belongs_to :user
  has_many   :donations
  has_one    :spotus_donation

  def credit_covers_total?
    self.total_amount_in_cents == 0
  end

  def donations=(donations)
    @new_donations = donations
  end

  def total_amount
    return self[:total_amount_in_cents].to_dollars unless self[:total_amount_in_cents].blank?
    (donations_sum - credit_to_apply).to_dollars
  end

  protected

  # total of all donations in cents
  def donations_sum
    amount = 0
    amount += donations.map(&:amount_in_cents).sum unless donations.blank?
    amount += @new_donations.map(&:amount_in_cents).sum unless @new_donations.blank?
    amount += spotus_donation.amount_in_cents if spotus_donation
    amount
  end

  def set_total_amount_in_cents
    self[:total_amount_in_cents] = total_amount.to_cents
  end

  def apply_credits
    Credit.create(:user => self.user, :description => "Applied to Purchase #{id}",
                  :amount_in_cents => (0 - credit_to_apply))
  end

  def build_credit_card
    @credit_card = ActiveMerchant::Billing::CreditCard.new(credit_card_hash)
  end

  def validate_credit_card
    unless credit_card.valid?
      credit_card.errors.each do |field, messages|
        messages.each do |message|
          errors.add(:"credit_card_#{field}", message)
        end
      end
    end
  end

  def associate_donations
    (@new_donations || []).each do |donation|
      donation.purchase = self
      donation.pay!
    end
  end

  def associate_spotus_donations
    user.unpaid_spotus_donation.update_attribute(:purchase_id, self.id) if user.unpaid_spotus_donation
  end


  def set_credit_card_number_ending
    if credit_card_number
      self.credit_card_number_ending ||= credit_card_number.last(4)
    end
  end

  def credit_to_apply
    return 0 if user.nil?
    [user.total_credits_in_cents, donations_sum].min
  end

  def bill_credit_card
    return true if credit_covers_total?
    response = gateway.purchase(total_amount_in_cents,
                                credit_card,
                                billing_hash)
    unless response.success?
      raise GatewayError, response.message
    end
  end

  private

  def billing_hash
    { :billing_address => { :address1 => address1,
                            :address2 => address2,
                            :city     => city,
                            :state    => state,
                            :zip      => zip,
                            :country  => 'US',
                            :email    => email } }
  end


  def credit_card_hash
    { :first_name         => first_name,
      :last_name          => last_name,
      :number             => credit_card_number,
      :month              => credit_card_month,
      :year               => credit_card_year,
      :verification_value => verification_value,
      :type               => credit_card_type }
  end

  def email
    user.nil? ? nil : user.email
  end

end
