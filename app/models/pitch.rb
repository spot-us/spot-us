# == Schema Information
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
#  requested_amount_in_cents   :integer(4)
#  current_funding_in_cents    :integer(4)      default(0)
#  status                      :string(255)
#  feature                     :boolean(1)
#  fact_checker_id             :integer(4)
#

class Pitch < NewsItem
  aasm_initial_state  :active

  aasm_state :active
  aasm_state :accepted
  aasm_state :funded

  aasm_event :fund do
    transitions :from => :active, :to => :funded, :on_transition => :do_fund_events
  end

  aasm_event :accept do
    transitions :from => :active, :to => :accepted, :on_transition => :do_fund_events
  end

  validates_presence_of :requested_amount
  validates_presence_of :short_description
  validates_presence_of :extended_description
  validates_presence_of :delivery_description
  validates_presence_of :skills
  validates_presence_of :featured_image_caption

  if Rails.env.production?
    validates_presence_of :featured_image_file_name
  end

  has_dollar_field :requested_amount
  has_dollar_field :current_funding

  # Next :accept required because of rails bug:
  # http://skwpspace.com/2008/02/21/validates_acceptance_of-behavior-in-rails-20/
  validates_acceptance_of :contract_agreement, :accept => true, :allow_nil => false
  validates_inclusion_of :location, :in => LOCATIONS

  has_many :affiliations, :dependent => :destroy
  has_many :tips, :through => :affiliations
  has_many :donations, :dependent => :destroy do
    def for_user(user)
      find_all_by_user_id(user.id)
    end

    def total_amount_in_cents_for_user(user)
      for_user(user).map(&:amount_in_cents).sum
    end
  end
  has_many :supporters, :through => :donations, :source => :user, :order => "donations.created_at", :uniq => true
  has_one :story, :foreign_key => 'news_item_id', :dependent => :destroy
  before_save :dispatch_fact_checker
  after_save :check_if_funded_state

  named_scope :most_funded, :order => 'news_items.current_funding_in_cents DESC'
  named_scope :featured, :conditions => {:feature => true}
  named_scope :almost_funded, :order => "(news_items.current_funding_in_cents / news_items.requested_amount_in_cents) desc"
  named_scope :sorted, lambda {|direction| { :order => "created_at #{direction}" } }
  named_scope :unpublished, :conditions => 'id NOT IN(SELECT news_item_id FROM news_items WHERE type = "Story" AND status = "published")'

  MAX_PER_USER_DONATION_PERCENTAGE = 0.20

  def can_be_accepted?
    active?
  end

  def editable_by?(user)
    if user.nil?
      false
    else
      ((self.user == user) && (donations.paid.blank? && active?)) || user.admin?
    end
  end

  def featured?
    self.feature
  end

  def current_funding_in_percentage
    (current_funding_in_cents.to_f/requested_amount_in_cents.to_f)
  end

  def check_if_funded_state
    if fully_funded? && active?
      fund!
    end
  end

  def self.createable_by?(user)
    user && user.reporter?
  end

  def make_featured
    pitch = Pitch.featured.first
    pitch.update_attribute(:feature, false) unless pitch.nil?
    self.update_attribute(:feature, true)
  end

  def funding_needed_in_cents
    return 0 unless active?
    requested_amount_in_cents - total_amount_donated.to_cents
  end

  def featureable_by?(user)
    user.is_a?(Admin)
  end

  def fully_funded?
    return true if accepted? || funded?
    donations.paid.sum(:amount_in_cents) >= requested_amount_in_cents
  end

  def total_amount_donated
    donations.paid.sum(:amount_in_cents).to_dollars
  end

  def donated_to?
    donations.paid.any?
  end

  def donation_limit_per_user_in_cents
    requested_amount_in_cents * MAX_PER_USER_DONATION_PERCENTAGE
  end

  def max_donation_amount_in_cents(user)
    if user.organization? || (funding_needed_in_cents < donation_limit_per_user_in_cents)
      funding_needed_in_cents
    else
      donation_limit_per_user_in_cents
    end
  end

  def user_can_donate_more?(user, attempted_donation_amount_in_cents)
    return false if attempted_donation_amount_in_cents.nil?
    return false if attempted_donation_amount_in_cents > funding_needed_in_cents
    user_donations_in_cents = donations.paid.total_amount_in_cents_for_user(user)
    (user_donations_in_cents + attempted_donation_amount_in_cents) <= max_donation_amount_in_cents(user)
  end

  def dispatch_fact_checker
    if self.fact_checker_id_changed? && self.story && self.valid?
      self.story.update_attribute(:fact_checker_id, self.fact_checker_id)
    end
  end

  protected
    def do_fund_events
      send_fund_notification
      create_associated_story
    end

    def create_associated_story
      self.create_story(:headline => self.headline, :location => self.location, :user => self.user)
    end

    def send_fund_notification
      Mailer.deliver_pitch_accepted_notification(self)
    end
end
