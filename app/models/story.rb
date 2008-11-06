# == Schema Information
#
# Table name: news_items
#
#  id                          :integer(4)      not null, primary key
#  headline                    :string(255)     
#  location                    :string(255)     
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
#  video_embed                 :text            
#  featured_image_caption      :string(255)     
#  user_id                     :integer(4)      
#  requested_amount_in_cents   :integer(4)      
#  current_funding_in_cents    :integer(4)      default(0)
#  status                      :string(255)     
#  feature                     :boolean(1)      
#  fact_checker_id             :integer(4)      
#

class Story < NewsItem
  aasm_initial_state  :draft
  
  aasm_state :draft
  aasm_state :fact_check
  aasm_state :ready
  aasm_state :published
  
  aasm_event :verify do
    transitions :from => :draft, :to => :fact_check
  end
  
  aasm_event :reject do
    transitions :from => :fact_check, :to => :draft
  end
  
  aasm_event :accept do
    transitions :from => :fact_check, :to => :ready
  end
  
  aasm_event :publish do
    transitions :from => :ready, :to => :published
  end

  belongs_to :pitch, :foreign_key => 'news_item_id'
  validate_on_update :extended_description
end
