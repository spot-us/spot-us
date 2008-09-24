class Purchase < ActiveRecord::Base

  class GatewayError < RuntimeError; end

  before_validation_on_create :build_credit_card, :set_total,
    :set_credit_card_number_ending

  validates_presence_of :first_name, :last_name, :credit_card_number_ending,
    :address1, :city, :state, :zip, :user_id, :total_amount_in_cents
  validates_presence_of :credit_card_number, :credit_card_year,
    :credit_card_type, :credit_card_month, :verification_value, :on => :create
  validate :validate_credit_card, :on => :create

  belongs_to :user
  has_many   :donations

  after_create :associate_donations
  before_create :bill_credit_card

  cattr_accessor :gateway

  attr_accessor :credit_card_number, :credit_card_year, :credit_card_month,
    :credit_card_type, :verification_value
  attr_reader :credit_card

  def donations=(donations)
    @new_donations = donations
    set_total
  end

  protected

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
      donation.paid = true
      donation.save!
    end
  end

  def set_total
    self.total_amount_in_cents = 
      (@new_donations || []).inject(0) do |sum, donation|
        sum + donation.amount_in_cents
      end
  end

  def set_credit_card_number_ending
    if credit_card_number
      self.credit_card_number_ending ||= credit_card_number.last(4)
    end
  end

  def bill_credit_card
    response = gateway.purchase(total_amount_in_cents,
                                credit_card,
                                billing_hash)
    unless response.success?
      raise GatewayError, response.message
    end
  end

  private

  def credit_card_hash
    { :first_name         => first_name,
      :last_name          => last_name,
      :number             => credit_card_number,
      :month              => credit_card_month,
      :year               => credit_card_year,
      :verification_value => verification_value,
      :type               => credit_card_type }
  end

  def billing_hash
    { :billing_address => { :address1 => address1,
                            :address2 => address2,
                            :city     => city,
                            :state    => state,
                            :zip      => zip,
                            :country  => 'US',
                            :email    => email } }
  end

  def email
    user.nil? ? nil : user.email
  end

end
