require "url_shortener"

class Post < ActiveRecord::Base
  
  include ActionController::UrlWriter
  include Utils
  
  belongs_to :pitch
  belongs_to :user
  
  after_save :touch_pitch
  
  has_attached_file :blog_image,
                      :styles => { :thumb => '50x50#', 
                          :medium => "200x150#", 
                          :front_story => "300x163#", 
                          :medium_alt=>"215x180#", 
                          :medium_alt_1=>"268x210#" },
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
  
  def blog_image_name
    blog_image_file_name.blank?
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
    max_length = PREPEND_STATUS_UPDATE.length + share_type.length + url_length + 15
    msg  = "#{PREPEND_STATUS_UPDATE} #{share_type}: "
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

end
