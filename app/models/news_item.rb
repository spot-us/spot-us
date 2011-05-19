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

require "url_shortener"

class NewsItem < ActiveRecord::Base
  include HasTopics
  include AASMWithFixes
  include Sanitizy
  include NetworkMethods
  include Utils
  
  cattr_accessor :per_page
  @@per_page = 10
  
  cleanse_columns(:external_links) do |sanitizer|
    sanitizer.allowed_tags.delete('div')
  end

  cleanse_columns(:video_embed, :widget_embed) do |sanitizer|
    sanitizer.allowed_tags.replace(%w(object param embed a img))
    sanitizer.allowed_attributes.replace(%w(width height name src value allowFullScreen type href allowScriptAccess style wmode pluginspage classid codebase data quality))
  end
  before_save :clean_columns


  acts_as_paranoid
  aasm_column :status
  belongs_to :user
  belongs_to :category
  belongs_to :parent, :class_name => 'NewsItem', :foreign_key => "news_item_id"
  belongs_to :fact_checker, :class_name => 'User'
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :clickstreams, :as => :clickstreamable
  
  has_attached_file :featured_image,
                    :styles => { :thumb => '50x50#', 
                        :medium => "200x150#", 
                        :front_story => "300x163#", 
                        :medium_alt=>"215x180#", 
                        :medium_alt_1=>"268x210#", :larger_featured_image => '670x320', :featured_image => '520x320', :small_hero => '300x165#' },
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :bucket =>   S3_BUCKET,
                    :path => "news_items/" <<
                             ":attachment/:id_partition/" <<
                             ":basename_:style.:extension",
                    :url =>  "news_items/:attachment/:id_partition/" <<
                             ":basename_:style.:extension",
                    :default_url => "/images/featured_images/missing_:style.png"

  validates_presence_of :headline, :user_id
  validates_length_of :slug, :within => 15..30, :message => "Your slug has to be between 15-30 characters long"

  unless Rails.env.development?
    validates_attachment_content_type :featured_image,
      :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png',
                        'image/x-png', 'image/jpg'],
      :message      => "Oops! Make sure you are uploading an image file.",
      :unless => :featured_image_name

    validates_attachment_size :featured_image, :in => 1..5.megabytes, :unless => :featured_image_name
  end
  
  define_index do
    indexes headline, :sortable => true
    indexes slug, :sortable => true
    indexes excerpt, :sortable => true
    indexes short_description, :sortable => true
    indexes extended_description, :sortable => true
    indexes status, :sortable => true
    
    has user_id, created_at, updated_at
  end
  
  named_scope :newest, :include => :user, :order => 'news_items.created_at DESC'
  
  named_scope :featured, :conditions => {:feature => true}, :order => "news_items.created_at desc"
  named_scope :unfunded, :conditions => "news_items.status NOT IN('accepted','funded','closed')"
  named_scope :funded, :conditions => "news_items.status IN ('accepted','funded')"
  named_scope :almost_funded, :select => "news_items.*, case when news_items.status = 'active' then (1.0 - (news_items.current_funding / news_items.requested_amount)) else news_items.created_at end as sort_value", :order => "sort_value ASC"
  named_scope :published, :conditions => {:status => 'published'}
  named_scope :suggested, :conditions => "news_items.type='Tip' AND news_items.status NOT IN ('unapproved','draft','closed')"
  named_scope :browsable, :include => :user, :conditions => "news_items.status != 'unapproved' and news_items.status != 'closed'"
  named_scope :recent, :order => 'news_items.created_at DESC', :conditions => "news_items.status NOT IN ('unapproved','draft','closed','')"
  
  named_scope :accepted, :conditions => "news_items.status NOT IN ('unapproved','draft','closed','')"
  named_scope :approved, :conditions => "news_items.status NOT IN ('unapproved','draft', 'closed')"
  named_scope :unfunded_with_no_story, :conditions => "news_items.status='active' and news_item_id is null"
  named_scope :pitch_or_tip, :conditions => 'news_items.type IN("Pitch","Tip")'
  named_scope :top_four, :limit => 4
  named_scope :desc, :order => 'news_items.created_at DESC'
  named_scope :asc, :order => 'news_items.created_at ASC'
  named_scope :fundable_news_item, :conditions => ['news_items.type in (?)', ["Pitch", "Tip"]]
  named_scope :by_network, lambda {|network|
    return {} unless network
    { :conditions => { :network_id => network.id } }
  }
  named_scope :constrain_topic, lambda {|topic|
    return {} unless topic
    { :conditions => " topics.seo_name='#{topic.seo_name}'" , :include => :topics }
  }
  named_scope :all_news_items
  named_scope :exclude_type, lambda {|type| { :conditions => ['news_items.type != ?', type] } }

  named_scope :constrain_type, lambda{ |type|
    news_item_type = MODEL_NAMES[type]
    news_item_type = 'Pitch' unless news_item_type
    { :conditions => { :type => news_item_type } }
  }
  
  named_scope :order_results, lambda { |type|
    return {} if type=='almost-funded'
    return { :order=>"news_items.created_at desc" }
  }
  
  named_scope :constrain_topic_id, lambda{ |topic_id|
    topic_id = -1 unless topic_id
    return {} if topic_id.to_i<=0
    { :include=>[:topics], :conditions=>["topics.id=?", topic_id] }
  }
  
  named_scope :constrain_grouping_id, lambda{ |grouping_id|
    grouping_id = -1 unless grouping_id
    return {} if grouping_id.to_i<=0
    return { :joins => 'inner join groupings_users gu on gu.user_id=news_items.user_id', :conditions=>["gu.grouping_id=?", grouping_id] }
  }
  
  cattr_reader :per_page
  @@per_page = 12
 
  def featured_image_name
    featured_image_file_name.blank? && (type.to_s=='Story' || type.to_s=='Tip')
  end

  def excerpt?
    return (self.short_description ? self.short_description : self.extended_description).to_s.strip_and_shorten
  end


  def validate
    return valid_excerpt unless excerpt.blank?
    return true
  end
  
  def valid_excerpt
    unless excerpt.blank?
      excerpt_length = excerpt.strip_html.split(' ').length
      if excerpt_length<30 || excerpt_length>250
        errors.add("wrong_excerpt_length", "Your overview &amp; elevator pitch must be between 30 to 250 words") 
        return false
      else
        return true
      end
    else
      return true
    end
  end

	# def network_id
	# 	APP_CONFIG[:has_networks] ? network_id : 0 #APP_CONFIG[:all_network]
	# end

  # NOTE: You can chain scopes off of with_sort, but you can't chain with_sort off of scopes.
  # Well, you can, but you will lose the previous scopes.
  def self.with_sort(sort='desc')
    self.send(sanitize_sort(sort))
  end

  def self.sanitize_sort(sort)
    %w(desc asc most_pledged most_funded almost_funded).include?(sort) ? sort : 'desc'
  end
  
  def self.get_stories(page, topic_id, grouping_id, topic, selected_filter, current_network, limit=nil)
    having_cache ["news_items_stories_", page, topic_id, grouping_id, topic, selected_filter, current_network, limit], {:expires_in => CACHE_TIMEOUT }  do
      unless limit
        self.constrain_topic_id(topic_id).constrain_grouping_id(grouping_id).constrain_type(selected_filter).constrain_topic(topic).send(selected_filter.gsub('-','_')).order_results(selected_filter).browsable.by_network(current_network).paginate(:page => page)
      else
        self.constrain_topic_id(topic_id).constrain_grouping_id(grouping_id).constrain_type(selected_filter).constrain_topic(topic).send(selected_filter.gsub('-','_')).order_results(selected_filter).browsable.by_network(current_network).find(:all,:limit=>limit)
      end
    end
  end
  
  def peer_reviewer
    # fact_checker || (parent && parent.fact_checker)
    return nil if !["Pitch","Story"].include?(self.class.to_s)
    item = self.class.to_s == "Pitch" ? self : self.pitch
    if item.assignments.any?
      assignment = item.assignments.find(:first, :conditions=>"is_factchecker_assignment=1")
      return assignment.accepted_contributors.last if assignment && assignment.is_closed?
    else
      return (item.fact_checker || (item.parent && item.parent.fact_checker))
    end
    return nil   
  end

  def to_s
    headline
  end
  
  def to_param
    begin 
      "#{id}-#{to_s.parameterize}"
    rescue
      "#{id}"
    end
  end
  
  def short_url(start_url=nil,base_url=nil)
    base_url  = "http://#{APP_CONFIG[:default_host]}/" unless base_url
    base_url += "#{type.to_s.downcase.pluralize}/"
    authorize = UrlShortener::Authorize.new APP_CONFIG[:bitly][:login], APP_CONFIG[:bitly][:api_key]
    client = UrlShortener::Client.new(authorize)
    shorten = client.shorten("#{base_url}#{to_param}")
    shorten.urls
  end
  
  def status_update(show_url=true)
    url_length = show_url ? 22 : 0
    share_type = type.to_s.titleize
    max_length = PREPEND_STATUS_UPDATE.length + share_type.length + url_length + 15
    msg  = "#{PREPEND_STATUS_UPDATE} #{share_type}: "
    msg += headline.length > 140-max_length ? "#{headline[0..max_length].gsub(/\w+$/, '')}..." : headline
    msg += " - #{short_url}" if show_url
    msg
  end
  
  def update_twitter
    #unless Rails.env.development?
    #debugger
    if user.notify_twitter
      msg = status_update
      [user, User.info_account?].compact.uniq.each do |u|
        u.twitter_credential.update?(msg) if u && u.twitter_credential
      end
    end
    #end
  end
  
  def update_facebook
    #unless Rails.env.development?
    if user.notify_facebook_wall
      description = ""
      description = strip_html(self.excerpt) if self.excerpt
      description = strip_html(self.short_description) if self.short_description && description.blank?
      description = strip_html(self.extended_description) if self.extended_description && description.blank?
      description = "#{description[0..200]}..." if description.length>200
      [self.user, User.info_account?].compact.uniq.each do |u|
        u.save_async_post("Spot.Us #{type.to_s.titleize}", description, self.short_url, self.featured_image.url, self.headline) if u && u.facebook_user?
      end
    end
    #end
  end
  
  def deleted?
    !deleted_at.blank?
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
  
  def comment_subscribers
    author = user.notify_comments ? [user] : nil
    comment_subscribers = comments.map(&:user).find_all{|user| user.notify_comments}.uniq
    (author + comment_subscribers).uniq
  end

  def clean_columns
  	self.extended_description 		= self.extended_description.sanitize if self.extended_description
  	self.short_description 			  = self.short_description.sanitize if self.short_description
  	self.skills 					        = self.skills.sanitize if self.skills
  	self.delivery_description 		= self.delivery_description.sanitize if self.delivery_description
  end
  
  def excerpt?
    return excerpt unless excerpt.blank?
    if short_description
      short_body = short_description.gsub(/<\/?[^>]*>/, "")
      short_body = short_body.length>1000 ? (short_description[0..1000].gsub(/\w+$/, '')+"...").sanitize : short_description.sanitize
    else
      short_body = ""
    end
    
    return short_body
  end
  
  def slug?
    return slug unless slug.blank?
    if headline
      short_headline = headline.length>30 ? headline[0..26].gsub(/\w+$/, '')+"..." : headline
    else
      short_headline = ""
    end
    
    return short_headline
  end

end


