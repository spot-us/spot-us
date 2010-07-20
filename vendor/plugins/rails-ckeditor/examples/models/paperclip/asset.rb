class Asset < ActiveRecord::Base

  # === List of columns ===
  #   id                : integer 
  #   data_file_name    : string 
  #   data_content_type : string 
  #   data_file_size    : integer 
  #   assetable_id      : integer 
  #   assetable_type    : string 
  #   type              : string 
  #   locale            : integer 
  #   user_id           : integer 
  #   created_at        : datetime 
  #   updated_at        : datetime 
  # =======================

  
  belongs_to :user
  belongs_to :assetable, :polymorphic => true
  
  def url(*args)
    data.url(*args)
  end
  
  def filename
    data_file_name
  end
  
  def content_type
    data_content_type
  end
  
  def size
    data_file_size
  end
  
  def to_xml(options = {})
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])

    xml.tag!(self.type.to_s.downcase) do
      xml.filename{ xml.cdata!(self.filename) }
      xml.size self.size
      xml.path{ xml.cdata!(self.url) }
      
      xml.styles do
        self.styles.each do |style|
          xml.tag!(t.style, self.url(style))
        end
      end unless self.styles.empty?
    end
    
  end
end
