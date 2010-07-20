class AttachmentFile < Asset

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
  
  has_attachment :storage => :file_system, :path_prefix => 'public/attachments/files',
                 :max_size => 10.megabytes
  
  validates_as_attachment
  
  named_scope :masters, :conditions => {:parent_id => nil}
  
  # Map file extensions to mime types.
  # Thanks to bug in Flash 8 the content type is always set to application/octet-stream.
  # From: http://blog.airbladesoftware.com/2007/8/8/uploading-files-with-swfupload
  def swf_uploaded_data=(data)
    data.content_type = MIME::Types.type_for(data.original_filename)
    self.uploaded_data = data
  end
  
  def full_filename(thumbnail = nil)
    file_system_path = self.attachment_options[:path_prefix]
    File.join(RAILS_ROOT, file_system_path, file_name_for(self.id))
  end
  
  def file_name_for(asset = nil)
    extension = filename.scan(/\.\w+$/)
    return "#{asset}_#{filename}"
  end
end
