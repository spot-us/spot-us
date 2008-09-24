class NewsItem < ActiveRecord::Base
  belongs_to :user
  
  has_attached_file :featured_image, 
                    :styles => { :thumb => '50x50#', :medium => "200x150#" }, 
                    :path => ":rails_root/public/system/news_items/" <<
                             ":attachment/:id_partition/" <<
                             ":basename_:style.:extension",
                    :url =>  "/system/news_items/:attachment/:id_partition/" <<
                             ":basename_:style.:extension"
  
  validates_presence_of :location, :headline, :user_id

  validates_attachment_content_type :featured_image,
    :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 
                      'image/x-png', 'image/jpg'], 
    :message      => "Oops! Make sure you are uploading an image file." 

  validates_attachment_size :featured_image, :in => 1..5.megabytes

  named_scope :newest, :order => 'news_items.created_at DESC'

  def editable_by?(user)
    self.user == user
  end

  def tip?
    is_a?(Tip)
  end

  def pitch?
    is_a?(Pitch)
  end

end
