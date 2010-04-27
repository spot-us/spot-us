require "url_shortener"

class Post < ActiveRecord::Base
  
  include ActionController::UrlWriter
  
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
    msg += title.length > 140-max_length ? "#{headline[0..max_length].gsub(/\w+$/, '')}..." : title
    msg += " - #{short_url}" if show_url
    msg
  end
  
  def update_twitter
    require 'twitter_update'
    TwitterUpdate.update_status?(status_update)
  end
  
  def blog_posted_notification
    #email supporters
    emails = self.pitch.supporters.map{ |email| "'#{email}'"}
    self.pitch.supporters.each do |supporter|
      Mailer.deliver_blog_posted_notification(self, supporter.first_name, supporter.email)
    end
    #email admins
    emails = emails.concat(Admin.all.map{ |email| "'#{email}'"}).uniq
    Admin.find(:all,:conditions=>"email!='kara@spot.us' and email not in (#{emails.join(',')})").each do |admin|
      Mailer.deliver_blog_posted_notification(self, admin.first_name, admin.email)
    end
    #email subscribers
    self.pitch.subscribers.find(:all,:conditions=>"email not in (#{emails.join(',')})").each do |subscriber|
      Mailer.deliver_blog_posted_notification(self, "Subscriber", subscriber.email, subscriber)
    end
    update_twitter
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
