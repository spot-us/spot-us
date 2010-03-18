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

class Tip < NewsItem
  attr_accessor :pledge_amount

  has_many :pledges, :dependent => :destroy
  has_many :supporters, :through => :pledges, :source => :user, :order => "pledges.created_at", :uniq => true
  has_many :affiliations, :dependent => :destroy
  has_many :pitches, :through => :affiliations

  before_create :build_initial_pledge

  validates_presence_of :short_description
  validates_presence_of :user
  validates_presence_of :pledge_amount, :on => :create

  named_scope :most_pledged, :order => "(select sum(amount) from pledges where pledges.tip_id = #{table_name}.id) DESC"

  def self.createable_by?(user)
    !user.nil?
  end
 
  def editable_by?(user)
    if user.nil?
      false
    else
      ((self.user == user) && !pledged_to?) || user.admin?
    end
  end
  
  def pledged_to?
    # we don't count the initial pledge, which is self-given
    pledges.size > 1
  end

  def total_amount_pledged
    pledges.sum(:amount)
  end

  private

  def build_initial_pledge
    pledges.build(:user_id => user_id, :amount => pledge_amount)
  end
end

