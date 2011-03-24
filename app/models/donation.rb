# == Schema Information
# Schema version: 20090218144012
#
# Table name: donations
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  pitch_id    :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#  purchase_id :integer(4)
#  status      :string(255)     default("unpaid")
#  amount      :decimal(15, 2)
#

class Donation < ActiveRecord::Base
  include Utils
  DEFAULT_AMOUNT = 20

  cattr_reader :per_page
  @@per_page = 10

  attr_accessor :applying_credits
  @@applying_credits = false

  include AASM
  class << self
    alias invasive_inherited_from_aasm inherited
    def inherited(child)
      invasive_inherited_from_aasm(child)
      super
    end
  end
  aasm_column :status
  aasm_initial_state  :unpaid

  aasm_state :unpaid
  aasm_state :paid
  aasm_state :refunded

  aasm_event :pay do
    transitions :from => :unpaid, :to => :paid 
  end

  aasm_event :refund do
    transitions :from => :paid, :to => :refunded
  end

  belongs_to :user
  belongs_to :pitch
  belongs_to :purchase
  belongs_to :credit
  belongs_to :group
  belongs_to :cca
  validates_presence_of :pitch_id
  validates_presence_of :user_id
  validates_presence_of :amount
  validates_numericality_of :amount, :greater_than => 0
  validate_on_update :disable_updating_paid_donations, :check_donation, :if => lambda { |me| me.pitch }
  validate_on_create :check_donation, :if => lambda { |me| me.pitch }
  
  #default_scope :conditions => {:donation_type => "payment"}
  named_scope :unpaid, :conditions => "status = 'unpaid'"
  named_scope :paid, :conditions => "donations.status = 'paid'"
  named_scope :from_organizations, :include => :user, :conditions => "users.type = 'organization'"
  named_scope :for_pitch, lambda {|pitch| { :conditions => {:pitch_id => pitch.id} } }
  named_scope :by_user, lambda {|user| { :conditions => {:user_id => user.id} } }
  named_scope :other_than, lambda {|donation| { :conditions => "id != #{donation.id}" } }
  
  named_scope :cca_supporters, lambda { |pitch_id|
    {
      :select => 'credits.cca_id, sum(credits.amount) as cca_total_amount', 
      :joins => 'INNER JOIN credits ON credits.id=donations.credit_id', 
      :conditions => ['cca_id is not null and pitch_id=?', pitch_id], 
      :group => 'cca_id'
    }
  }
  named_scope :by_network, lambda {|network|
    return {} unless network
    { :joins=>"INNER JOIN news_items ON news_items.id=donations.pitch_id", :conditions=>["news_items.network_id=? AND news_items.type='Pitch'", network.id] }
  }
  
  after_save :update_twitter, :update_facebook, :update_pitch_funding, :send_thank_you, :if => lambda {|me| me.paid?}

  def self.createable_by?(user)
    user
  end

  # TODO: remove this 'bandaid' method when conversion complete
  def amount_in_cents
    return 0 if amount.nil?
    (amount * 100).to_i
  end

  def editable_by?(user)
    self.user == user
  end

  def deletable_by?(user)
    return false if user.nil?
    (user.admin? || self.user == user) && !self.paid? 
  end
  
  def status_update(show_url=true, admin=false)
    url_length = show_url ? 22 : 0
    max_length = PREPEND_STATUS_UPDATE.length + url_length + 23
    msg  = "#{PREPEND_STATUS_UPDATE} Donation: "
    title = "I have just donated to "
    msg += title.length > 140-max_length ? "#{pitch.headline[0..max_length].gsub(/\w+$/, '')}..." : title
    msg += " - #{short_url}" if show_url
    msg
  end
  
  def short_url(start_url=nil,base_url=nil)
    base_url  = "http://#{APP_CONFIG[:default_host]}/" unless base_url
    base_url += "pitches/"
    authorize = UrlShortener::Authorize.new APP_CONFIG[:bitly][:login], APP_CONFIG[:bitly][:api_key]
    client = UrlShortener::Client.new(authorize)
    shorten = client.shorten("#{base_url}#{pitch.to_param}")
    shorten.urls
  end

  def self.old_donors
    find(:all, :order=>'created_at asc', :limit=>100).map(&:user).uniq.map(&:email).join(",")
  end

  protected

  def send_thank_you
    Mailer.deliver_user_thank_you_for_donating(self) unless BlacklistEmail.find_by_email(self.user.email)
  end



  def update_twitter
    #unless Rails.env.development?
       if user && user.twitter_credential && user.notify_twitter
         user.twitter_credential.update?(status_update) 
       end
    #end
  end
  
  def update_facebook
    #unless Rails.env.development?
      if user.notify_facebook_wall
        description = strip_html(pitch.short_description)
        description = "#{description[0..200]}..." if description.length>200
        user.save_async_post("Spot.Us Donation: I have just donated to this pitch.", description, pitch.short_url, pitch.featured_image.url, pitch.headline) if user
      end
    #end
  end
  
  def update_pitch_funding
    pitch.current_funding = pitch.total_amount_donated.to_f       # make sure the proper donation amounts are always used
    pitch.save
  end

  def disable_updating_paid_donations
    if paid? && !being_marked_as_paid?
      errors.add_to_base('Paid donations cannot be updated')
    end
  end

  def being_marked_as_paid?
    status_changed? && status_was == 'unpaid'
  end
  
  def keep_under_user_limit
    #debugger
    if self.amount > self.pitch.max_donation_amount(user) - self.pitch.total_amount_allocated_by_user(user)
      if self.id # updating 
        self.amount = pitch.max_donation_amount(user) - pitch.donations.by_user(user).other_than(self).map(&:amount).sum + 
          pitch.credit_pitches.by_user(user).other_than(self).map(&:amount).sum
      else # creating
        self.amount = pitch.max_donation_amount(user) - pitch.donations.by_user(user).map(&:amount).sum + 
          pitch.credit_pitches.by_user(user).map(&:amount).sum
      end
    end
  end
  
  def limit_to_existing_donation
    #debugger
    existing_donation = pitch.donations.unpaid.by_user(user).map(&:amount).sum #Donation.unpaid.find(:all, :conditions => "pitch_id = #{pitch.id} and user_id = #{user.id}").map(&:amount).sum
    if existing_donation > 0
      self.amount = existing_donation
    end
  end
  
  def check_credit
    #debugger
    # limit if not an org and the amount is greater than the pitch/user's remaining limit (under 20% of pitch total)
    if !user.organization? 
      keep_under_user_limit
    end
    
    # do not run these rules when you are applying the credits...
    unless applying_credits
      limit_to_existing_donation
      # limit if amount is greater than the remaining funding sought for pitch
      if self.amount > pitch.requested_amount - pitch.current_funding
        self.amount = pitch.requested_amount - pitch.current_funding
      end 
    end
  end

  def check_donation
    if pitch.fully_funded?
      errors.add_to_base("Great news! This pitch is already fully funded therefore it can't be donated to any longer.")
      return
    end

    if donation_type == "credit"
        check_credit
    end
    unless pitch.user_can_donate_more?(user, self.amount)
      errors.add_to_base("Thanks for your support but we only allow donations of 20% of requested amount from one user. Please lower your donation amount and try again.")
      return
    end
  end

  def self.find_all_from_paypal(paypal_params)
    strip_spotus_donations(paypal_params)
    items = paypal_params.select{|k,v| k =~ /item_number/}
    return [] if items.blank?
    donation_keys = items.collect{|a| a.first}
    donation_ids = donation_keys.map{|k| paypal_params.values_at(k)}.flatten
    Donation.find(donation_ids)
  end

  def self.strip_spotus_donations(paypal_params)
    if spotus_keys = paypal_params.detect{|k,v| v =~ /support spot\.us/i}
      paypal_params.delete(spotus_keys.first.gsub(/name/, 'number'))
      paypal_params.delete(spotus_keys.first)
    end
  end
  
  def self.has_enough_credits?(credit_pitch_amounts, user)
      credit_total = 0
      credit_pitch_amounts.values.each do |val|
        credit_total += val["amount"].to_f
      end
      return true if credit_total <= user.total_credits
      return false
  end
end

