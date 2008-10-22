# == Schema Information
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  email                     :string(255)     
#  crypted_password          :string(40)      
#  salt                      :string(40)      
#  created_at                :datetime        
#  updated_at                :datetime        
#  remember_token            :string(255)     
#  remember_token_expires_at :datetime        
#  first_name                :string(255)     
#  last_name                 :string(255)     
#  type                      :string(255)     
#  photo_file_name           :string(255)     
#  photo_content_type        :string(255)     
#  photo_file_size           :integer(4)      
#  location                  :string(255)     
#  about_you                 :text            
#  website                   :string(255)     
#  address1                  :string(255)     
#  address2                  :string(255)     
#  city                      :string(255)     
#  state                     :string(255)     
#  zip                       :string(255)     
#  phone                     :string(255)     
#  country                   :string(255)     
#  notify_tips               :boolean(1)      not null
#  notify_pitches            :boolean(1)      not null
#  notify_stories            :boolean(1)      not null
#  notify_spotus_news        :boolean(1)      not null
#  fact_check_interest       :boolean(1)      not null
#  status                    :string(255)     default("active")
#  organization_name         :string(255)     
#  established_year          :string(255)     
#

require 'digest/sha1'
class User < ActiveRecord::Base

  include HasTopics
  include AASM
  class <<self
    alias invasive_inherited_from_aasm inherited
    def inherited(child)
      invasive_inherited_from_aasm(child)
      super
    end
  end
  aasm_column :status
  aasm_initial_state  :active
  aasm_state :active
  
  has_many :donations
  has_many :tips
  has_many :pitches
  has_many :pledges
  has_many :pledged_tips, :through => :pledges, :source => :pledge
  has_many :jobs
  has_many :samples
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :email, :first_name, :last_name
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?, :on => :update
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?, :on => :update
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_inclusion_of    :type, :in => %w(Citizen Reporter Organization Admin)
  validates_acceptance_of   :terms_of_service
  validates_inclusion_of    :location, :in => LOCATIONS
  validates_format_of       :website, :with => %r{^http://}, :allow_blank => true
  validate                  :validate_new_donation_amounts, 
    :on => :update, 
    :if => lambda {|user| user.donation_amounts_changed? }
  before_save :encrypt_password
  before_validation_on_create :generate_password, :set_default_location

  after_create :deliver_signup_notification
  after_update :update_donation_amounts,
    :if => lambda {|user| user.donation_amounts_changed? }

  has_attached_file :photo, 
                    :styles      => { :thumb => '50x50#' }, 
                    :path        => ":rails_root/public/system/profiles/" << 
                                    ":attachment/:id_partition/" <<
                                    ":basename_:style.:extension",
                    :url         => "/system/profiles/:attachment/:id_partition/" <<
                                    ":basename_:style.:extension",
                    :default_url => "/images/default_avatar.png"
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :about_you, :address1, :address2, :city, :country,
    :donation_amounts, :email, :fact_check_interest, :first_name, :last_name,
    :location, :notify_pitches, :notify_spotus_news, :notify_stories,
    :notify_tips, :password, :password_confirmation, :phone, :photo, :state,
    :terms_of_service, :topics_params, :website, :zip, :organization_name, 
    :established_year
  named_scope :fact_checkers, :conditions => {:fact_check_interest => true}
  named_scope :approved_news_orgs, :conditions => {:status => 'approved'}
  named_scope :unapproved_news_orgs, :conditions => {:status => 'needs_approval'}

  def citizen?
    self.is_a? Citizen
  end
  
  def reporter?
    self.is_a? Reporter
  end

  def organization?
    self.is_a? Organization
  end
  
  def admin?
    self.is_a? Admin
  end

  def self.createable_by?(user)
    true
  end

  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find_by_email(email) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end
  
  def self.generate_csv
    FasterCSV.generate do |csv|
      # header row
      csv << ["email", "first_name", "last_name", "location", 
              "notify_tips", "notify_pitches",  "notify_pitches", 
              "notify_stories", "notify_spotus_news", "fact_check_interest"]

      # data rows
      User.all.each do |user|
        csv << [user.email, user.first_name, user.last_name, 
                user.location, user.notify_tips, user.notify_pitches, 
                user.notify_stories, user.notify_spotus_news, user.fact_check_interest]
      end
    end
  end

  def editable_by?(user)
    (user == self)
  end

  def amount_pledged_to(tip)
    tip.pledges.find_by_user_id(id).amount
  end

  def amount_donated_to(pitch)
    pitch.donations.find_all_by_user_id(id).map(&:amount_in_cents).sum.to_dollars
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def reset_password!
    self.password = nil
    generate_password
    save!
    Mailer.deliver_password_reset_notification(self)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def donation_amounts=(amounts)
    @changed_donations = []
    amounts.each do |donation_id, new_amount|
      if donation = donations.unpaid.find_by_id(donation_id)
        donation.amount = new_amount
        @changed_donations << donation
      end
    end
  end

  def donation_amounts_changed?
    !@changed_donations.blank?
  end

  def has_donation_for?(pitch)
    donations.exists?(:pitch_id => pitch.id )
  end

  def has_pledge_for?(tip)
    pledges.exists?(:tip_id => tip.id )
  end

  protected

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def generate_password
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a - %w(l o 0 1 i I L)
    self.password ||= (1..6).collect { chars[rand(chars.size)] }.join
    self.password_confirmation = password
  end
  
  def deliver_signup_notification
    return if self.type == "Admin"
    Mailer.send(:"deliver_#{self.type.downcase}_signup_notification", self)    
  end

  def set_default_location
    self.location ||= LOCATIONS.first
  end

  def update_donation_amounts
    @changed_donations.each(&:save!)
  end

  def validate_new_donation_amounts
    @changed_donations.each do |donation|
      unless donation.valid?
        donation.errors.full_messages.each do |error|
          errors.add_to_base(error)
        end
      end
    end
  end
end

