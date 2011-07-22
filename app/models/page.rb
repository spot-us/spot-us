class Page < ActiveRecord::Base
  
  before_save :clean_columns
  
  validates_presence_of :title, :body, :slug
  validates_uniqueness_of :slug, :on => :create, :message => "You can only have one page per slug"
  
  has_attached_file :featured_image,
                      :styles => { :thumb => '50x50#', 
                          :medium => "200x150#", :front_story => "300x163#", :medium_alt=>"215x180#", 
                          :medium_alt_1=>"268x210#", :larger_featured_image => '670x320', :featured_image => '520x320', 
                          :small_hero => '300x165#' },
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
      :allow_nil => true

    validates_attachment_size :featured_image, :in => 1..5.megabytes, :allow_nil => true
  end
  
  def slug?
    slug.downcase
  end
  
  def clean_columns
    self.slug      = self.title.to_param if self.slug.blank?
    self.slug      = self.slug.downcase unless self.slug.blank?
  	self.body      = self.body.sanitize if self.body
  end
  
end
