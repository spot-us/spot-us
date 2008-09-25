class Pitch < NewsItem
  validates_presence_of :requested_amount
  validates_presence_of :short_description
  validates_presence_of :extended_description
  validates_presence_of :delivery_description
  validates_presence_of :keywords
  validates_presence_of :skills
  validates_presence_of :featured_image_caption
  validates_presence_of :featured_image_file_name

  # Next :accept required because of rails bug: 
  # http://skwpspace.com/2008/02/21/validates_acceptance_of-behavior-in-rails-20/
  validates_acceptance_of :contract_agreement, :accept => true, :allow_nil => false
  validates_inclusion_of :location, :in => LOCATIONS

  has_many :affiliations
  has_many :tips, :through => :affiliations
  has_many :donations
  has_many :supporters, :through => :donations, :source => :user, :order => "donations.created_at", :uniq => true

  def total_amount_donated
    donations.sum(:amount_in_cents).to_dollars
  end

  def donated_to?
    donations.any?
  end
end
