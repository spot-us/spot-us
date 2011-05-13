require "url_shortener"

class Post < ActiveRecord::Base
  
  include ActionController::UrlWriter
  include Utils
  
  cattr_accessor :per_page
  @@per_page = 10
  
  belongs_to :pitch
  belongs_to :user
  has_many :clickstreams, :as => :clickstreamable
  
  after_save :touch_pitch
  before_save :clean_columns
  
  has_attached_file :blog_image,
                      :styles => { :thumb => '50x50#', 
                          :medium => "200x150#", 
                          :front_story => "300x163#", 
                          :medium_alt=>"215x180#", 
                          :medium_alt_1=>"268x210#", :larger_featured_image => '670x320', :featured_image => '520x320', :small_hero => '300x165#' },
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :bucket =>   S3_BUCKET,
                      :path => "posts/" <<
                               ":attachment/:id_partition/" <<
                               ":basename_:style.:extension",
                      :url =>  "posts/:attachment/:id_partition/" <<
                               ":basename_:style.:extension",
                      :default_url => "/images/featured_images/missing_:style.png"
                      
  #if Rails.env.production?
    validates_attachment_content_type :blog_image,
      :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png',
                        'image/x-png', 'image/jpg'],
      :message      => "Oops! Make sure you are uploading an image file.",
      :unless => :blog_image_name

    validates_attachment_size :blog_image, :in => 1..5.megabytes, :unless => :blog_image_name
  #end
  validates_presence_of :title, :body, :user, :pitch
  
  define_index do
    indexes title, :sortable => true
    indexes body, :sortable => true
    
    has user_id, created_at, updated_at
  end
  
  def blog_image_name
    blog_image_file_name.blank?
  end
  
  def validate
    if TEXT[:title]==title
      errors.add("", "You have to specify a title") 
      return false
    end
    return true
  end
  
  def to_s
    title
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
    base_url += "pitches/"
    authorize = UrlShortener::Authorize.new APP_CONFIG[:bitly][:login], APP_CONFIG[:bitly][:api_key]
    client = UrlShortener::Client.new(authorize)
    shorten = client.shorten("#{base_url}#{pitch.to_param}/posts/#{id}")
    shorten.urls
  end
  
  def status_update(show_url=true)
    url_length = show_url ? 22 : 0
    share_type = type.to_s.titleize
    if SHOW_PREPEND_FOR_STORY_UPDATES
      max_length = PREPEND_STATUS_UPDATE.length + url_length + 15
      msg  = "#{PREPEND_STATUS_UPDATE}: "
    else
      max_length = url_length + 15
      msg  = ""
    end
    msg += title.length > 140-max_length ? "#{title[0..max_length].gsub(/\w+$/, '')}..." : title
    msg += " - #{short_url}" if show_url
    msg
  end
  
  def update_facebook
    #unless Rails.env.development?
    if user.notify_facebook_wall
      description = strip_html(self.body)
      description = "#{description[0..200]}..." if description.length>200
      [self.user, User.info_account?].compact.uniq.each do |u|
        u.save_async_post("Spot.Us Blog Post", description, self.short_url, self.blog_image.url, self.title) if u && u.facebook_user?
      end
    end
    #end
  end
  
  def excerpt?
    return excerpt unless excerpt.blank?
    if body
      short_body = body.gsub(/<\/?[^>]*>/, "")
      short_body = body[0..500].gsub(/\w+$/, '')+"..." if short_body.length>500
    else
      short_body = ""
    end
    
    return short_body
  end
  
  def slug?
    if title
      short_headline = title.length>30 ? title[0..30].gsub(/\w+$/, '')+"..." : title
    else
      short_headline = ""
    end
    
    return short_headline
  end
  
  def update_twitter
    #unless Rails.env.development?
    if user.notify_twitter
      msg = status_update
      [user, User.info_account?].compact.uniq.each do |u|
        u.twitter_credential.update?(msg) if u && u.twitter_credential
      end
    end
    #end
  end
  
  def blog_posted_notification
    emails = BlacklistEmail.all.map{ |be| "'#{be.email}'"}
    conditions = ""
    
    #email supporters
    conditions = "email not in (#{emails.join(',')})" if emails && !emails.empty?
    self.pitch.supporters.find(:all,:conditions=>conditions).each do |supporter|
      Mailer.deliver_blog_posted_notification(self, supporter.first_name, supporter.email) if supporter.notify_blog_posts
    end
    emails = emails.concat(self.pitch.supporters.map{ |s| "'#{s.email}'"})
    
    #email admins
    conditions = "email not in (#{emails.join(',')})" if emails && !emails.empty?
    Admin.find(:all,:conditions=>"email!='kara@spot.us' and email not in (#{emails.join(',')})").each do |admin|
      Mailer.deliver_blog_posted_notification(self, admin.first_name, admin.email)
    end
    emails = emails.concat(Admin.all.map{ |admin| "'#{admin.email}'"}).uniq
    
    #email subscribers
    conditions = "email not in (#{emails.join(',')})" if emails && !emails.empty?
    self.pitch.subscribers.find(:all,:conditions=>conditions).each do |subscriber|
      Mailer.deliver_blog_posted_notification(self, "Subscriber", subscriber.email, subscriber)
    end
    
    update_twitter
    update_facebook
  end
  
  def blog_image_display(style)
    return blog_image.url(style) if blog_image_file_name
    return pitch.featured_image.url(style)
  end
  
  named_scope :by_network, lambda {|network|
    return {} unless network
    {:conditions =>  ["pitch_id in (select id from news_items where network_id in (select id from networks where id = ?))", network]}
    }
    named_scope :latest, :order => "posts.id desc", :limit => 3
    
  def touch_pitch
    self.pitch.touch_pitch!
  end
  
  def clean_columns
  	self.body 		= self.body.sanitize if self.body
  end

end
