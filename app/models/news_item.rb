class NewsItem < ActiveRecord::Base
  has_attached_file :featured_image, 
                    :styles => { :thumb => '50x50#', :medium => "250x150#" }, 
                    :path => ":rails_root/public/system/news_items/:attachment/:id_partition/:basename_:style.:extension",
                    :url =>                    "/system/news_items/:attachment/:id_partition/:basename_:style.:extension"
  
end
