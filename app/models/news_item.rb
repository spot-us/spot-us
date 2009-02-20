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

class NewsItem < ActiveRecord::Base
  include HasTopics
  include AASMWithFixes
  include Sanitizy
  include NetworkValidation

  cleanse_columns(:delivery_description, :extended_description, :short_description) do |sanitizer|
    sanitizer.allowed_tags.delete('div')
  end

  cleanse_columns(:video_embed, :widget_embed) do |sanitizer|
    sanitizer.allowed_tags.replace(%w(object param embed a img))
    sanitizer.allowed_attributes.replace(%w(width height name src value allowFullScreen type href allowScriptAccess style wmode pluginspage classid codebase data quality))
  end

  acts_as_paranoid
  aasm_column :status
  belongs_to :user
  belongs_to :network
  belongs_to :category
  belongs_to :fact_checker, :class_name => 'User'
  has_many :comments, :as => :commentable, :dependent => :destroy

  has_attached_file :featured_image,
                    :styles => { :thumb => '50x50#', :medium => "200x150#" },
                    :path => ":rails_root/public/system/news_items/" <<
                             ":attachment/:id_partition/" <<
                             ":basename_:style.:extension",
                    :url =>  "/system/news_items/:attachment/:id_partition/" <<
                             ":basename_:style.:extension",
                    :default_url => "/images/featured_images/missing_:style.png"

  validates_presence_of :headline, :user_id, :network_id

  if Rails.env.production?
    validates_attachment_content_type :featured_image,
      :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png',
                        'image/x-png', 'image/jpg'],
      :message      => "Oops! Make sure you are uploading an image file."

    validates_attachment_size :featured_image, :in => 1..5.megabytes
  end

  named_scope :newest, :order => 'news_items.created_at DESC'
  named_scope :unfunded, :conditions => "status NOT IN('accepted','funded')"
  named_scope :pitch_or_tip, :conditions => 'type IN("Pitch","Tip")'
  named_scope :top_four, :limit => 4
  named_scope :desc, :order => 'news_items.created_at DESC'
  named_scope :asc, :order => 'news_items.created_at ASC'
  named_scope :fundable_news_item, :conditions => ['type in (?)', ["Pitch", "Tip"]]
  named_scope :by_network_id, lambda {|network_id| { :conditions => { :network_id => network_id } } }
  named_scope :all_news_items


  cattr_reader :per_page
  @@per_page = 10

  def self.by_network(network=nil)
    return all_news_items unless network
    by_network_id(network.id)
  end

  # NOTE: You can chain scopes off of with_sort, but you can't chain with_sort off of scopes.
  # Well, you can, but you will lose the previous scopes.
  def self.with_sort(sort='desc')
    self.send(sanitize_sort(sort))
  end

  def self.sanitize_sort(sort)
    %w(desc asc most_pledged most_funded almost_funded).include?(sort) ? sort : 'desc'
  end

  def editable_by?(user)
    if user.nil?
      false
    else
      (self.user == user) || user.admin?
    end
  end

  def tip?
    is_a?(Tip)
  end

  def pitch?
    is_a?(Pitch)
  end

  def network_and_category
    return "No network selected" unless network
    output = network.display_name
    output += "- #{category.name}" if category
    output
  end
end


