# == Schema Information
# Schema version: 20090218144012
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
#  status                    :string(255)
#  organization_name         :string(255)
#  established_year          :string(255)
#  deleted_at                :datetime
#  activation_code           :string(255)
#

require 'digest/sha1'
require 'zlib'
class User < ActiveRecord::Base
  acts_as_paranoid
  include HasTopics
  include AASMWithFixes
  include NetworkMethods
  include OauthConnect
  TYPES = ["Citizen", "Reporter", "Organization", "Admin", "Sponsor"]
  CREATABLE_TYPES = TYPES - ["Admin"]

  cattr_accessor :per_page
  @@per_page = 10
  
  aasm_column :status
  aasm_state :inactive
  aasm_state :active
  aasm_initial_state  :inactive
  aasm_event :activate do
    transitions :from => :inactive, :to => :active,
      :on_transition => lambda{ |user|
        user.send(:deliver_signup_notification)
        user.send(:clear_activation_code)
      }
    transitions :from => :approved, :to => :active,
      :on_transition => lambda{ |user|
        user.send(:clear_activation_code)
      }
  end

  has_one :twitter_credential
  has_many :async_posts
  has_and_belongs_to_many :groupings
  has_many :clickstreams, :as => :clickstreamable
  
  belongs_to :category

  has_many :donations, :conditions => {:donation_type => "payment"} do
    def pitch_sum(pitch)
      self.paid.all(:conditions => {:pitch_id => pitch}).map(&:amount).sum
    end
  end
  
  has_many :credit_pitches, :class_name => "Donation", :conditions => {:donation_type => "credit"} do
    def pitch_sum(pitch)
      self.paid.all(:conditions => {:pitch_id => pitch}).map(&:amount).sum
    end
  end
  has_many :paid_donations, :conditions => {:donation_type => "payment", :status => "paid"}
  
  has_many :all_donations, :class_name => "Donation" do
    def pitch_sum(pitch)
      self.paid.all(:conditions => {:pitch_id => pitch}).map(&:amount).sum
    end
    def total_amount
      self.paid.all.map(&:amount).sum
    end
    def nr_of_donations
      self.paid.count
    end 
  end

  has_many :spotus_donations
  has_many :tips
  has_many :pitches
  has_many :posts
  has_many :stories
  has_many :jobs
  has_many :samples
  has_many :credits
  has_many :assignments
  has_many :ccas, :primary_key=>'id', :foreign_key=>'sponsor_id'

  has_many :comments
  has_many :contributor_applications
  has_many :pledges do
    def tip_sum(tip)
      self.all(:conditions => {:tip_id => tip}).map(&:amount).sum
    end
  end
  
  named_scope :section?, lambda { |section|
    return {} if section.blank?
    self.send(section)
  }

  # Virtual attribute for the unencrypted password
  attr_accessor :password
  cattr_accessor :fb_session
  
  validates_presence_of     :email, :first_name, :last_name
  validates_presence_of     :password, :password_confirmation, :if => :should_validate_password?
  validates_length_of       :password, :within => 4..40,       :if => :should_validate_password?
  validates_confirmation_of :password,                         :if => :should_validate_password?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false, :scope => :deleted_at
  validates_inclusion_of    :type, :in => User::TYPES
  validates_acceptance_of   :terms_of_service
  validates_format_of       :website, :with => %r{^http://}, :allow_blank => true

  before_validation_on_create :generate_activation_code
  before_save :encrypt_password, :unless => lambda {|user| user.password.blank? }
  # after_create :register_user_to_fb
  
  has_attached_file :photo,
                    :styles      => { :thumb => '44x44#', :mini_thumb => '32x32#', :featured_image => '520x320', :small_hero => '300x165#' },
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :bucket =>   S3_BUCKET,
                    :path        => "profiles/" <<
                                    ":attachment/:id_partition/" <<
                                    ":basename_:style.:extension",
                    :url         => "profiles/:attachment/:id_partition/" <<
                                    ":basename_:style.:extension",
                    :default_url => "/images/default_avatar.png"

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :about_you, :address1, :address2, :city, :country,
    :email, :fact_check_interest, :first_name, :last_name,
    :location, :notify_blog_posts, :notify_comments, :notify_pitches, :notify_spotus_news, :notify_stories,
    :notify_tips,:notify_facebook_wall,:notify_twitter, :password, :password_confirmation, :phone, :photo, :state,
    :terms_of_service, :topics_params, :website, :zip, :organization_name,
    :established_year, :network_id, :category_id
  named_scope :fact_checkers, :conditions => {:fact_check_interest => true}
  named_scope :approved_news_orgs, :conditions => {:status => 'approved'}
  named_scope :unapproved_news_orgs, :conditions => {:status => 'needs_approval'}
  named_scope :sponsors_and_admins, :conditions => 'type="Admin" OR type="Sponsor"'
  
  define_index do
    indexes about_you, :sortable => true
    indexes first_name, :sortable => true
    indexes last_name, :sortable => true
    indexes organization_name, :sortable => true
    indexes email, :sortable => true
    
    has created_at, updated_at
  end
  
  def self.opt_in_defaults
    { :notify_blog_posts => true,
      :notify_comments => true,
      :notify_tips => true,
      :notify_pitches => true,
      :notify_stories => true,
      :notify_spotus_news => true }
  end

  def self.new(options = nil, &block)
    options = (options || {}).stringify_keys
    options.merge!(opt_in_defaults)
    if User::CREATABLE_TYPES.include?(options["type"])
      returning compute_type(options["type"]).allocate do |model|
        model.send(:initialize, options, &block)
      end
    elsif options["type"].blank?
      super
    else
      raise ArgumentError, "invalid subclass of #{inspect}"
    end
  end

  def self.get_contributor_count(is_admin=false)
    having_cache ["contributor_count_"], { :expires_in => 86400, :force => is_admin }  do
      (count / 50.0).floor * 50
    end
  end

################### new facebook oauth 2 ###############

	def link_identity!(uid)
		self.fb_user_id = uid
		self.save!
	end
	
	# def network_id
	# 	APP_CONFIG[:has_networks] ? network_id : 0 #APP_CONFIG[:all_network]
	# end
	
	def self.from_identity(credentials)
		user = User.find_by_fb_user_id(credentials["id"].to_i)
		return user if user
		new_user = User.new(:first_name => credentials["first_name"], :last_name => credentials["last_name"], :login => "facebook_#{credentials["id"]}", 
			:password => "", :email => "", :network_id => Network.first)
    new_user.type = "Citizen"
    new_user.status = "active"
    new_user.fb_user_id = credentials["id"]
    #We need to save without validations
    new_user.save(false)
	  return new_user
	end
	
	def self.info_account?
    return User.find_by_email(APP_CONFIG[:site][:info_account_email]) if APP_CONFIG[:site] && APP_CONFIG[:site][:info_account_email]
    nil
  end
	
  def self.find_by_fb_user(uid)
    User.find_by_fb_user_id(uid) # || User.find_by_email_hash(fb_user.email_hashes)
  end
  
  def connect_fb(new_fb_user)
    self.fb_user_id = new_fb_user.fb_user_id
    self.save!
    new_fb_user.destroy!
  end
  
  def post_fb_wall(args)
    #unless Rails.env.development?
      if self.notify_facebook_wall              # this will now not be necessary but I will keep it still...
        return false if args[:message].blank? || self.fb_session.blank?
        query_string = args.collect {|k,v| "#{k.to_s}=#{v}" if v}.to_a.compact.uniq.join("&")
        access_token = fb_access_token(self.fb_session) 
        access_token.post('/me/feed?' + query_string) if access_token
      end
    #end
  end
  
  def save_async_post(message, description, link, picture, title)
    #unless Rails.env.development?
      if self.notify_facebook_wall
        ap = AsyncPost.new
        ap.user_id = id
        ap.post_type = 'Facebook'
        ap.message = message
        ap.description = description
        ap.link = link
        ap.picture = picture
        ap.title = title
        ap.save
      end
    #end
  end
  
  def facebook_user?
    return !fb_user_id.nil? && fb_user_id > 0
  end

########### end facebook ##############

  def twitter_connected?
	  twitter_credential && twitter_credential.access_token
  end

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
  
  def sponsor?
    self.is_a? Sponsor
  end

  def total_credits_in_cents
    (total_credits * 100).to_i
  end

  def total_credits
    #self.credits.map(&:amount).sum.to_f
    self.total_available_credits.map(&:amount).sum.to_f
  end
  
  def total_available_credits
    self.credits - self.all_donations.find(:all, :conditions=>"credit_id is not null", :include=>:credit).map(&:credit) - self.spotus_donations.find(:all, :conditions=>"credit_id is not null", :include=>:credit).map(&:credit)
  end
  
  def remaining_credits
    total_credits - self.credit_pitches.unpaid.map(&:amount).sum.to_f
  end
  
  def allocated_credits?(credit_these_pitches)
    credit_these_pitches.map(&:amount).sum.to_f
  end
  
  def allocated_credits
    self.credit_pitches.unpaid.map(&:amount).sum.to_f
  end
  
  def has_enough_credits?(credit_pitch_amounts)
      credit_total = 0
      credit_pitch_amounts.values.each do |val|
        credit_total += val["amount"].to_f
      end
      return true if credit_total <= self.total_credits
      return false
  end
  
  def apply_credit_pitches?(credit_these_pitches)
      #refactor - there must be a nicer ruby-like way to do this
      transaction do 
        credit_pitch_ids = credit_these_pitches.map{|credit_pitch| [credit_pitch.pitch.id]}.join(", ")
        credit = Credit.create(:user => self, :description => "Applied to Pitches (#{credit_pitch_ids})",
                        :amount => (0 - self.allocated_credits?(credit_these_pitches)))
        credit_these_pitches.each do |credit_pitch|
          credit_pitch.credit_id = credit.id
          credit_pitch.pay!
        end
      end 
  end
  
  #depricated
  def apply_credit_pitches
      #refactor - there must be a nicer ruby-like way to do this
      
      transaction do 
        credit_pitch_ids = self.credit_pitches.unpaid.map{|credit_pitch| [credit_pitch.pitch.id]}.join(", ")
        credit = Credit.create(:user => self, :description => "Applied to Pitches (#{credit_pitch_ids})",
                        :amount => (0 - self.allocated_credits))
        self.credit_pitches.unpaid.each do |credit_pitch|
          credit_pitch.credit_id = credit.id
          credit_pitch.pay!
        end
      end 
  end

  def self.createable_by?(user)
    true
  end

  def credits?
    total_credits > 0
  end
  
  def current_balance
    unpaid_donations_sum + current_spotus_donation.amount #unpaid_donations_sum - allocated_credits + current_spotus_donation.amount
  end
  
  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find_by_email(email) # need to get the salt
    return nil unless u && u.activated?
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def self.generate_csv
    FasterCSV.generate do |csv|
      # header row
      csv << ["type", "email", "first_name", "last_name", "network", "notify_blog_posts", "notify_comments",
              "notify_tips", "notify_pitches",  "notify_pitches",
              "notify_stories", "notify_spotus_news", "fact_check_interest"]

      # data rows
      User.all.each do |user|
        csv << [user.type, user.email, user.first_name, user.last_name,
                user.network.name, user.notify_blog_posts, user.notify_comments, user.notify_tips, user.notify_pitches,
                user.notify_stories, user.notify_spotus_news, user.fact_check_interest]
      end
    end
  end

  def editable_by?(user)
    (user == self)
  end

  def amount_pledged_to(tip)
    self.pledges.tip_sum(tip)
  end

  def amount_donated_to(pitch)
    self.donations.pitch_sum(pitch) + self.credit_pitches.pitch_sum(pitch)
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def reset_password!
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a - %w(l o 0 1 i I L)
    string = (1..6).collect { chars[rand(chars.size)] }.join
    update_attributes(:password => string, :password_confirmation => string)
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

  def activated?
    !activation_code?
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def has_donation_for?(pitch)
    donations.exists?(:pitch_id => pitch.id )
  end

  def has_donated_to?(pitch)
    donations.paid.exists?(:pitch_id => pitch.id)
  end

  def max_donation_for(pitch)
    @max_dontation_for ||= calculate_max_donation(pitch)
  end
  
  def calculate_max_donation(pitch)
    pitch.max_donation_amount(self) - pitch.donations.total_amount_for_user(self)
  end

  def can_donate_to?(pitch)
    @can_donate_to ||= check_can_donate_to(pitch)
  end
  
  def check_can_donate_to(pitch)
    pitch.donations.total_amount_for_user(self) < pitch.max_donation_amount(self)
  end
  
  # TODO: remove after updating all models with amount
  def unpaid_donations_sum_in_cents
    sum = 0
    sum = donations.unpaid.empty? ? 0 : donations.unpaid.map(&:amount_in_cents).sum
    sum = credit_pitches.unpaid.empty? ? 0 : credit_pitches.unpaid.map(&:amount_in_cents).sum.to_f
  end

  def unpaid_donations_sum
    sum = 0
    sum = donations.unpaid.empty? ? 0 : donations.unpaid.map(&:amount).sum
    sum = credit_pitches.unpaid.empty? ? 0 : credit_pitches.unpaid.map(&:amount).sum.to_f
  end

  def unpaid_spotus_donation
    spotus_donations.unpaid.first
  end

  def current_spotus_donation
    unpaid_spotus_donation || spotus_donations.build
  end

  def has_spotus_donation?
    spotus_donations.paid.any?
  end

  def paid_spotus_donations_sum
    has_spotus_donation? ? spotus_donations.paid.map(&:amount).sum : 0
  end

  def last_paid_spotus_donation
    spotus_donations.paid.last
  end

  def has_pledge_for?(tip)
    pledges.exists?(:tip_id => tip.id )
  end
  
  def get_about_you
    (about_you && !about_you.strip.blank? ? about_you : "<p>#{full_name} has not provided a short bio yet.</p>")
  end
  
  def to_s
    self.full_name
  end
  
  def to_param
    begin 
      "#{id}-#{to_s.parameterize}"
    rescue
      "#{id}"
    end
  end

  def touch_user!
    self.updated_at = Time.now
    self.save
  end

  protected
  
  def encrypt_password
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def should_validate_password?
    #debugger
    (crypted_password.blank? || !password.blank?) && !facebook_user?
  end

  def deliver_signup_notification
    return if self.type == "Admin"
    Mailer.send(:"deliver_#{self.type.downcase}_signup_notification", self)
  end

  def deliver_activation_email
    Mailer.deliver_activation_email(self)
  end

  def generate_activation_code
    entropy = Time.now.to_s.split(//).sort_by{rand}.join
    digest = Digest::SHA1.hexdigest(entropy)
    self.activation_code = Zlib.crc32(digest)
  end

  def clear_activation_code
    self.update_attribute(:activation_code, nil)
  end
  
end


