class Page < ActiveRecord::Base
  
  before_save :clean_columns
  
  validates_presence_of :title, :body, :slug
  validates_uniqueness_of :slug, :on => :create, :message => "You can only have one page per slug"
  
  has_attached_file :featured_image,
                      :styles => { :thumb => '50x50#', :featured_image => '700x450'},
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :bucket =>   S3_BUCKET,
                      :path => "pages/" <<
                               ":attachment/:id_partition/" <<
                               ":basename_:style.:extension",
                      :url =>  "pages/:attachment/:id_partition/" <<
                               ":basename_:style.:extension",
                      :default_url => "/images/featured_images/missing_:style.png"
                      
  if Rails.env.production?
    validates_attachment_content_type :featured_image,
      :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png',
                        'image/x-png', 'image/jpg'],
      :message      => "Oops! Make sure you are uploading an image file.",
      :unless => :featured_image_name

    validates_attachment_size :featured_image, :in => 1..5.megabytes, :unless => :featured_image_name
  end
  
  def slug?
    slug.downcase
  end
  
  def featured_image_name
    featured_image_file_name.blank?
  end
  
  def clean_columns
    self.slug      = self.title.to_param if self.slug.blank?
    self.slug      = self.slug.downcase unless self.slug.blank?
  	self.body      = self.body.sanitize if self.body
  end
  
end
