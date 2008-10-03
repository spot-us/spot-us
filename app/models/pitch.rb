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
#

class Pitch < NewsItem
  validates_presence_of :requested_amount
  validates_presence_of :short_description
  validates_presence_of :extended_description
  validates_presence_of :delivery_description
  validates_presence_of :keywords
  validates_presence_of :skills
  validates_presence_of :featured_image_caption
  validates_presence_of :featured_image_file_name
  
  has_dollar_field(:requested_amount)
  has_dollar_field(:current_funding)

  # Next :accept required because of rails bug: 
  # http://skwpspace.com/2008/02/21/validates_acceptance_of-behavior-in-rails-20/
  validates_acceptance_of :contract_agreement, :accept => true, :allow_nil => false
  validates_inclusion_of :location, :in => LOCATIONS

  has_many :affiliations
  has_many :tips, :through => :affiliations
  has_many :donations do
    def for_user(user)
      find_all_by_user_id(user.id)
    end
    
    def total_amount_in_cents_for_user(user)
      for_user(user).map(&:amount_in_cents).sum
    end
  end
  named_scope :most_funded, :order => 'news_items.current_funding_in_cents DESC'
  has_many :supporters, :through => :donations, :source => :user, :order => "donations.created_at", :uniq => true

  MAX_PER_USER_DONATION_PERCENTAGE = 0.20
  
  def self.createable_by?(user)
    user && user.reporter?
  end

  def self.featured
    newest.first
  end
  
  def funding_needed_in_cents
    requested_amount_in_cents - total_amount_donated.to_cents
  end  
  
  def fully_funded?
    donations.sum(:amount_in_cents) >= requested_amount_in_cents
  end

  def total_amount_donated
    donations.sum(:amount_in_cents).to_dollars
  end

  def donated_to?
    donations.any?
  end
  
  def user_can_donate_more?(user, attempted_donation_amount_in_cents)
    # return false if funding_needed_in_cents == 0
    return false if attempted_donation_amount_in_cents.nil?
    return false if attempted_donation_amount_in_cents > funding_needed_in_cents
    
    if user.organization?
      max_donation_amount_in_cents = funding_needed_in_cents
    else
      donation_limit_per_user_in_cents = requested_amount_in_cents * MAX_PER_USER_DONATION_PERCENTAGE
      
      if funding_needed_in_cents < donation_limit_per_user_in_cents
        max_donation_amount_in_cents = funding_needed_in_cents
      else
        max_donation_amount_in_cents = donation_limit_per_user_in_cents
      end
    end
    
    user_has_donated_so_far_in_cents = donations.total_amount_in_cents_for_user(user)
    (user_has_donated_so_far_in_cents + attempted_donation_amount_in_cents) <= max_donation_amount_in_cents
  end
end
