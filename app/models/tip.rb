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
#  status                      :string(255)     default("active")
#

class Tip < NewsItem
  attr_accessor :pledge_amount

  has_many :pledges
  has_many :supporters, :through => :pledges, :source => :user, :order => "pledges.created_at", :uniq => true
  has_many :affiliations
  has_many :pitches, :through => :affiliations

  before_create :build_initial_pledge
 
  validates_presence_of :short_description
  validates_presence_of :user
  validates_presence_of :pledge_amount, :on => :create

  validates_inclusion_of :location, :in => LOCATIONS

  def self.createable_by?(user)
    !user.nil?
  end

  def total_amount_pledged
    pledges.sum(:amount_in_cents).to_dollars
  end

  private

  def build_initial_pledge
    pledges.build(:user_id => user_id, :amount => pledge_amount)
  end
end
