# == Schema Information
#
# Table name: news_items
#
#  id                          :integer(4)      not null, primary key
#  headline                    :string(255)     
#  location                    :string(255)     
#  requested_amount            :string(255)     
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
#  video_embed                 :string(255)     
#  featured_image_caption      :string(255)     
#  user_id                     :integer(4)      
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

  # Next :accept required because of rails bug: 
  # http://skwpspace.com/2008/02/21/validates_acceptance_of-behavior-in-rails-20/
  validates_acceptance_of :contract_agreement, :accept => true, :allow_nil => false
  validates_inclusion_of :location, :in => LOCATIONS

  has_many :affiliations
  has_many :tips, :through => :affiliations
  has_many :donations
  has_many :supporters, :through => :donations, :source => :user, :order => "donations.created_at", :uniq => true

  def self.createable_by?(user)
    user && user.reporter?
  end

  def self.featured
    newest.first
  end

  def total_amount_donated
    donations.sum(:amount_in_cents).to_dollars
  end

  def donated_to?
    donations.any?
  end
end
