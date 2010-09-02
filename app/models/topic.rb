class Topic < ActiveRecord::Base
  validates_presence_of   :name
  validates_uniqueness_of :name
  has_many :topic_memberships
  
  after_create :set_seo_name
  
  has_attached_file :featured_image,
                    :styles => { :thumb => '50x50#', 
                        :medium => "200x150#", 
                        :front_story => "300x163#", 
                        :medium_alt=>"215x180#", 
                        :medium_alt_1=>"268x210#" },
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :bucket =>   S3_BUCKET,
                    :path => "topics/" <<
                             ":attachment/:id_partition/" <<
                             ":basename_:style.:extension",
                    :url =>  "topics/:attachment/:id_partition/" <<
                             ":basename_:style.:extension",
                    :default_url => "/images/featured_images/missing_:style.png"

  unless Rails.env.development?
    validates_attachment_content_type :featured_image,
      :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png',
                        'image/x-png', 'image/jpg'],
      :message      => "Oops! Make sure you are uploading an image file.",
      :unless => :featured_image_name

    validates_attachment_size :featured_image, :in => 1..5.megabytes, :unless => :featured_image_name
  end
  
  def featured_image_name
    featured_image_file_name.blank?
  end
  
  def set_seo_name
    self.update_attributes({ :seo_name => self.name.parameterize.to_s })
  end
  
end

# == Schema Information
# Schema version: 20090116200734
#
# Table name: topics
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

