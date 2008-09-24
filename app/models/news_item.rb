class NewsItem < ActiveRecord::Base
  has_attached_file :featured_image, 
                    :styles => { :thumb => '50x50#', :medium => "250x150#" }, 
                    :path => ":rails_root/public/system/news_items/:attachment/:id_partition/:basename_:style.:extension",
                    :url =>                    "/system/news_items/:attachment/:id_partition/:basename_:style.:extension"
  
  validates_presence_of :location, :headline

  validates_attachment_content_type :featured_image,
    :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg'], 
    :message => "Oops! Make sure you are uploading an image file." 
  validates_attachment_size :featured_image, :in => 1..5.megabytes
end
