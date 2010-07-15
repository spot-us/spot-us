class Picture < Asset

  # === List of columns ===
  #   id             : integer 
  #   parent_id      : integer 
  #   content_type   : string 
  #   filename       : string 
  #   thumbnail      : string 
  #   size           : integer 
  #   width          : integer 
  #   height         : integer 
  #   type           : string 
  #   user_id        : integer 
  #   assetable_id   : integer 
  #   assetable_type : string 
  #   created_at     : datetime 
  #   updated_at     : datetime 
  # =======================

  belongs_to :user
  has_attachment :content_type => :image, 
                 :storage => :file_system, :path_prefix => 'public/attachments/pictures',
                 :max_size => 2.megabytes,
                 :size => 0.kilobytes..2000.kilobytes,
                 :processor => 'Rmagick',
                 :thumbnails => { :content => '575>', :thumb => '100x100!' }
                 
	validates_as_attachment
	
  named_scope :masters, :conditions=>"parent_id IS NULL", :order=>'filename'
end
