class Pitch < ActiveRecord::Base
  has_attached_file :featured_image, :styles => { :thumb => '50x50#', :medium => "250x150#" }
end
