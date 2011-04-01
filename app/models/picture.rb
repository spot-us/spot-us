class Picture < ActiveRecord::Base
  
  belongs_to :cca
  has_many :normalized_tags
  has_many :tags
  has_many :users, :through => :tags
  
  # add the tag system...
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings
  has_many :normalized_tags, :through => :taggings
  
  has_many :turk_answers, :as => :turkable
  
  attr_accessor :taglist
  
  has_attached_file :photo,
                      :styles => { :thumb => '50x50#', :large => '643x500', :medium => '321x250' },
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :bucket =>   S3_BUCKET,
                      :path => "photos/" <<
                               ":attachment/:id_partition/" <<
                               ":basename_:style.:extension",
                      :url =>  "photos/:attachment/:id_partition/" <<
                               ":basename_:style.:extension",
                      :default_url => "/images/featured_images/missing_:style.png"
                      
  #if Rails.env.production?
    validates_attachment_content_type :photo,
      :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png',
                        'image/x-png', 'image/jpg'],
      :message      => "Oops! Make sure you are uploading an image file.",
      :unless => :no_photo_name

    validates_attachment_size :photo, :in => 1..5.megabytes, :unless => :no_photo_name
  #end
  
  named_scope :random, lambda { |cca_id, picture_ids_string|
    conditions = []
    conditions << "cca_id=#{cca_id}"
    conditions << "id not in (#{picture_ids_string})" unless picture_ids_string.blank?
    {:conditions => conditions.join(" and "), :order=>"rand()", :limit=>1}
  }
  
  def no_photo_name
    !photo_file_name.blank?
  end
  
end
