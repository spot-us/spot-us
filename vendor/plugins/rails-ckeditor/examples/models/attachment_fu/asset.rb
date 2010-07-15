class Asset < ActiveRecord::Base

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

  belongs_to :assetable, :polymorphic => true
  
  def to_xml(options = {})
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])

    xml.tag!(self.read_attribute(:type).to_s.downcase) do
      xml.filename{ xml.cdata!(self.filename) }
      xml.size self.size
      xml.path{ xml.cdata!(self.public_filename) }
      
      xml.thumbnails do
        self.thumbnails.each do |t|
          xml.tag!(t.thumbnail, self.public_filename(t.thumbnail))
        end
      end unless self.thumbnails.empty?
    end
  end
end
