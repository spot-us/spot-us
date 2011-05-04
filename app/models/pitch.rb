# == Schema Information
# Schema version: 20090218144012
#
# Table name: news_items
#
#  id                          :integer(4)      not null, primary key
#  headline                    :string(255)
#  location                    :string(255)
#  state                       :string(255)
#  short_description           :text
#  delivery_description        :text
#  extended_description        :text
#  skills                      :text
#  keywords                    :string(255)
#  deliver_text                :boolean(1)      not null
#  deliver_audio               :boolean(1)      not null
#  deliver_video               :boolean(1)      not null
#  deliver_photo               :boolean(1)      not null
#  contract_agreement          :boolean(1)      not null
#  expiration_date             :datetime
#  created_at                  :datetime
#  updated_at                  :datetime
#  featured_image_file_name    :string(255)
#  featured_image_content_type :string(255)
#  featured_image_file_size    :integer(4)
#  featured_image_updated_at   :datetime
#  type                        :string(255)
#  video_embed                 :text
#  featured_image_caption      :string(255)
#  user_id                     :integer(4)
#  status                      :string(255)
#  feature                     :boolean(1)
#  fact_checker_id             :integer(4)
#  news_item_id                :integer(4)
#  deleted_at                  :datetime
#  widget_embed                :text
#  requested_amount            :decimal(15, 2)
#  current_funding             :decimal(15, 2)
#

class Pitch < NewsItem
  # extend ActiveSupport::Memoizable
  aasm_initial_state  :unapproved

  after_create :send_thank_you

  aasm_state :unapproved
  aasm_state :active
  aasm_state :accepted
  aasm_state :funded
  aasm_state :closed

  aasm_event :unapprove do
    transitions :from => :active, :to => :unapproved
  end

  aasm_event :approve do
    transitions :from => :unapproved, :to => :active, :on_transition => :send_approved_notification
  end

  aasm_event :fund do
    transitions :from => [:unapproved, :active], :to => :funded, :on_transition => :do_fund_events
  end

  aasm_event :accept do
    transitions :from => [:unapproved, :active], :to => :accepted, :on_transition => :do_fund_events
  end
  
  aasm_event :close do
    transitions :from => [:unapproved, :active], :to => :closed, :on_transition => :do_close_events
  end
  
  validates_presence_of :requested_amount
  validates_presence_of :short_description
  #validates_presence_of :extended_description
  validates_presence_of :delivery_description
  validates_presence_of :skills
  # validates_presence_of :featured_image_caption
  validates_presence_of :expiration_date
  validate_on_create :expiration_date_cannot_be_in_the_past

  if Rails.env.production?
    validates_presence_of :featured_image_file_name
  end

  # Next :accept required because of rails bug:
  # http://skwpspace.com/2008/02/21/validates_acceptance_of-behavior-in-rails-20/
  validates_acceptance_of :contract_agreement, :accept => true, :allow_nil => false

  has_many :affiliations, :dependent => :destroy
  has_many :tips, :through => :affiliations
  has_many :organization_pitches, :foreign_key => :pitch_id
  has_many :supporting_organizations, :through => :organization_pitches, :source => :organization
  has_many :donations, :conditions => {:donation_type => "payment"}, :dependent => :destroy do
    def for_user(user)
      find_all_by_user_id(user.id)
    end

    def total_amount_for_user(user)
      for_user(user).map(&:amount).sum
    end
  end

  has_many :credit_pitches, :class_name => "Donation", :conditions => {:donation_type => "credit"}, :dependent => :destroy do
    def for_user(user)
      find_all_by_user_id(user.id)
    end

    def total_amount_for_user(user)
      for_user(user).map(&:amount).sum
    end
  end
  has_many :donations_and_credits, :class_name => "Donation"
  has_many :organizational_donors, :through => :donations_and_credits, :source => :user, :conditions=>"donations.status='paid'", :order => "donations.created_at", 
            :conditions => "users.type = 'organization'",
            :uniq => true
  
  has_many :cca_credits, :class_name=>'Donation', :conditions => "credit_id is not null and donations.status='paid' and credits.cca_id is not null", :uniq => true, :include => :credit   
  has_many :supporters, :through => :donations_and_credits, :source => :user, :conditions=>"donations.status='paid'", :order => "donations.created_at desc", :uniq => true
  has_many :blog_subscribers, :select => "users.email", :through => :donations, :source => :user, :conditions => "users.notify_blog_posts = 1", 
           :order => "donations.created_at", :uniq => true
  has_many :subscribers, :conditions => "subscribers.status = 'subscribed'"
  has_many :posts, :order => "created_at desc", :dependent => :destroy do
    def first(number)
      find(:all, :limit => number, :order => 'created_at DESC')
    end
  end
  has_many :incentives
  has_many :assignments, :order => "created_at desc", :dependent => :delete_all
  has_many :contributor_applications do
    def unapproved
      find_all_by_approved(false)
    end
  end
  has_many :contributors, :through => :contributor_applications, :source => :user, :conditions => ['contributor_applications.approved = ?', true]
  has_many :contributor_applicants, :through => :contributor_applications, :source => :user
  has_one :story, :foreign_key => 'news_item_id', :dependent => :destroy

  belongs_to :fact_checker, :class_name => 'User', :foreign_key => 'fact_checker_id'

  after_create :send_admin_notification, :create_peer_editor_assignment
  after_save :check_if_funded_state, :dispatch_fact_checker
  
  named_scope :most_funded, :order => 'news_items.current_funding DESC'
  named_scope :sorted, lambda {|direction| { :order => "news_items.created_at #{direction}" } }
  named_scope :without_a_story, :conditions => 'news_items.id NOT IN (SELECT news_item_id FROM news_items WHERE news_items.type = "Story" AND news_items.status = "published")'
  #named_scope :browsable, :include => :user, :conditions => "news_items.status != 'unapproved'"
  
  MAX_PER_USER_DONATION_PERCENTAGE = 0.20

  def self.all_active_reporters
    self.without_a_story.find(:all, :conditions=>"status='active'", :include=>:user, :group=>"user_id").map(&:user)
  end

  def self.featured_by_network(network=nil)
    return network.featured_pitches if network
    featured
    # Network.with_pitches.map do |network|
    #   network.featured_pitches
    # end.flatten
  end

  def get_incentives(is_admin=false)
    having_cache ["incentives_", id], { :expires_in => CACHE_TIMEOUT, :force => is_admin }  do
      incentives.find(:all, :order => "amount asc")
    end
  end

  def can_be_accepted?
    active?
  end

  def editable_by?(user)
    if user.nil?
      false
    else
      ((self.user == user) && ((unapproved? || active?))) || user.admin? #&& (donations.paid.blank? 
    end
  end

  def postable_by?(other_user)
    return false if other_user.nil?
    user == other_user || other_user.admin? || other_user == fact_checker || assignments.map{|a| a.accepted_contributors}.flatten.include?(other_user)
  end
  
  def assignable_by?(other_user)
    return false if other_user.nil?
    user == other_user || other_user.admin?
  end

  def approvable_by?(current_user)
    return false if current_user.nil?
    current_user.admin? && (active? || unapproved?)
  end

  def current_funding
    return total_amount_donated if accepted?
    return requested_amount if self[:current_funding] && self[:current_funding] > requested_amount
    self[:current_funding] || 0
  end

  def current_funding_in_percentage
    (current_funding/requested_amount)
  end
  
  def funding_in_percentage
    (current_funding_in_percentage*100).to_i>100 ? 100 : (current_funding_in_percentage*100).to_i
  end

  def check_if_funded_state
    if fully_funded? && active?
      fund!
    end
  end

  def self.with_sort(sort='desc')
    self.browsable.without_a_story.send(sanitize_sort(sort))
  end

  def self.createable_by?(user)
    !user.nil?
    #user && user.reporter? || user.organization?
  end

  def featured?
    self.feature
  end

  def show_support!(organization)
    supporting_organizations << organization unless supporting_organizations.include?(organization)
  end

  def apply_to_contribute(user)
    return false unless user
    unless contributors.include?(user)
      contributors << user
      Mailer.deliver_admin_reporting_team_notification(self)
      Mailer.deliver_reporter_reporting_team_notification(self)
      Mailer.deliver_applied_reporting_team_notification(self, user)
    end
  end

  def feature!
    self.update_attribute(:feature, true)
  end

  def unfeature!
    self.update_attribute(:feature, false)
  end

  def featureable_by?(user)
    user.is_a?(Admin)
  end

  def funding_needed
    return 0 unless active? || unapproved?
    requested_amount - total_amount_donated
  end

  def half_funded?
    return true if accepted? || funded?
    total_amount_donated > (requested_amount / 2)
  end

  def half_fund!(user)
    donations.unpaid.for_user(user).map(&:destroy)
    donations.create(:amount => requested_amount / 2, :user => user)
  end

  def fully_funded?
    return false if !total_amount_donated || !requested_amount
    return true if accepted? || funded?
    total_amount_donated >= requested_amount
  end

  def fully_fund!(user)
    donations.unpaid.for_user(user).map(&:destroy)
    donations.create(:amount => requested_amount, :user => user)
  end

  def requested_amount=(value)
    self[:requested_amount] = value.to_s.gsub(/[^\d\.]/, "") unless value.nil?
  end

  def total_amount_donated
    @total_amount_donated ||= calculate_total_amount_donated
  end
  
  def calculate_total_amount_donated
    donations.paid.map(&:amount).sum + credit_pitches.paid.map(&:amount).sum
  end
  
  def total_amount_allocated_by_user(user)
    @total_ammount_allocated ||= calculate_total_amount_allocated_by_user(user)
  end
  
  def calculate_total_amount_allocated_by_user(user)
    donations.by_user(user).map(&:amount).sum + credit_pitches.by_user(user).map(&:amount).sum
  end

  def donated_to?
    donations.paid.any?
  end

  def donation_limit_per_user
    requested_amount * MAX_PER_USER_DONATION_PERCENTAGE
  end

  def max_donation_amount(user)
    if user.organization? || (funding_needed < donation_limit_per_user)
      funding_needed
    else
      donation_limit_per_user
    end
  end

  def default_donation_amount
    [Donation::DEFAULT_AMOUNT, donation_limit_per_user, funding_needed].min
  end

  def user_can_donate_more?(user, attempted_donation_amount)
    return false if attempted_donation_amount.nil?
    return true if user.organization? && attempted_donation_amount <= requested_amount
    return false if attempted_donation_amount > funding_needed
    user_donations = donations.paid.total_amount_for_user(user) + credit_pitches.paid.total_amount_for_user(user)
    (user_donations + attempted_donation_amount) <= max_donation_amount(user)
  end

  def dispatch_fact_checker
    if self.fact_checker_id_changed? && self.story
      self.story.update_attribute(:fact_checker_id, self.fact_checker_id)
    end
  end

  def has_more_posts_than(number)
    posts.size > number
  end
  
  def has_more_assignments_than(number)
    assignments.size > number
  end

  def donating_groups
    Donation.paid.for_pitch(self).map(&:group).uniq.compact
  end

  def send_edited_notification
    Mailer.deliver_pitch_edited_notification(self) if active?
  end
  
  def touch_pitch!
    self.updated_at = Time.now
    self.save
  end
  
  def create_associated_story
    self.create_story(:headline => self.headline, :slug => self.slug?, :network => self.network, :category => self.category, :user => self.user, :featured_image_file_name => "")
  end
  
  protected

  def do_fund_events
    send_fund_notification unless story && story.published?
    #if the slug is not set for old pitches, force one temporarily...
    unless slug
      self.slug = slug?
      self.save
    end
    create_associated_story unless story
  end
  
  def do_close_events
  end

  def create_peer_editor_assignment
    Assignment.create(:pitch_id => self.id, :user_id => self.user.id, :title =>"Apply to be Peer Review Editor", :is_factchecker_assignment => true,
                      :body => ["The Peer-Review editor has three main responsibilities – to ensure fair and accurate reporting, ",
                      "to be a second pair of eyes before a story is published and to be a sounding board as the reporter develops a story.",
                      " At any time the Peer-Review editor can also report suspicious activities to Spot.Us."].join(""))
  end

  def send_fund_notification
    emails = BlacklistEmail.all.map{ |be| "'#{be.email}'"}
    conditions = ""
    
    #email supporters
    conditions = "email not in (#{emails.join(',')})" if emails && !emails.empty?
    self.supporters.find(:all,:conditions=>conditions).each do |supporter|
      Mailer.deliver_pitch_accepted_notification(self, supporter.first_name, supporter.email)
    end
    emails = emails.concat(self.supporters.map{ |s| "'#{s.email}'"})
    
    #email admins
    conditions = "email not in (#{emails.join(',')})" if emails && !emails.empty?
    Admin.find(:all,:conditions=>conditions).each do |admin|
      Mailer.deliver_pitch_accepted_notification(self, admin.first_name, admin.email)
    end
    emails = emails.concat(Admin.all.map{ |admin| "'#{admin.email}'"}).uniq
    
    #email subscribers
    conditions = "email not in (#{emails.join(',')})" if emails && !emails.empty?
    self.subscribers.find(:all,:conditions=>conditions).each do |subscriber|
      Mailer.deliver_pitch_accepted_notification(self, "Subscriber", subscriber.email, subscriber)
    end
  end

  def send_admin_notification
    Mailer.deliver_pitch_created_notification(self)
  end

  def send_approved_notification
    Mailer.deliver_pitch_approved_notification(self)
    update_twitter
    update_facebook
  end

  def expiration_date_cannot_be_in_the_past 
   errors.add(:expiration_date, "can't be in the past") if  !expiration_date.blank? and expiration_date < Date.today 
  end 
  
  def send_thank_you
    Mailer.deliver_thank_you_for_your_pitch(user, self)
  end

end

