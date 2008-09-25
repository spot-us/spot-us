# == Schema Information
#
# Table name: news_items
#
#  id                          :integer(4)      not null, primary key
#  headline                    :string(255)     
#  location                    :string(255)     
#  requested_amount            :string(255)     
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
#  video_embed                 :string(255)     
#  featured_image_caption      :string(255)     
#  user_id                     :integer(4)      
#

class NewsItem < ActiveRecord::Base
  belongs_to :user
  has_many   :topic_memberships, :as => :member
  has_many   :topics, :through => :topic_memberships
  
  has_attached_file :featured_image, 
                    :styles => { :thumb => '50x50#', :medium => "200x150#" }, 
                    :path => ":rails_root/public/system/news_items/" <<
                             ":attachment/:id_partition/" <<
                             ":basename_:style.:extension",
                    :url =>  "/system/news_items/:attachment/:id_partition/" <<
                             ":basename_:style.:extension",
                    :default_url => "/images/featured_images/missing_:style.png"
  
  validates_presence_of :location, :headline, :user_id

  validates_attachment_content_type :featured_image,
    :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 
                      'image/x-png', 'image/jpg'], 
    :message      => "Oops! Make sure you are uploading an image file." 

  validates_attachment_size :featured_image, :in => 1..5.megabytes

  named_scope :newest, :order => 'news_items.created_at DESC'
  named_scope :top_three, :limit => 3

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
