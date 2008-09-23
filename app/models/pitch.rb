# == Schema Information
#
# Table name: pitches
#
#  id                   :integer(4)      not null, primary key
#  headline             :string(255)     
#  location             :string(255)     
#  requested_amount     :string(255)     
#  state                :string(255)     
#  short_description    :text            
#  delivery_description :text            
#  extended_description :text            
#  skills               :text            
#  keywords             :text            
#  deliver_text         :boolean(1)      not null
#  deliver_audio        :boolean(1)      not null
#  deliver_video        :boolean(1)      not null
#  deliver_photo        :boolean(1)      not null
#  contract_agreement   :boolean(1)      not null
#  expiration_date      :datetime        
#  created_at           :datetime        
#  updated_at           :datetime        
#

class Pitch < NewsItem
  validates_presence_of :requested_amount
  validates_presence_of :short_description
  validates_presence_of :extended_description
  validates_presence_of :delivery_description
  validates_presence_of :keywords
  validates_presence_of :skills
  validates_presence_of :featured_image_caption

  # Next :accept required because of rails bug: 
  # http://skwpspace.com/2008/02/21/validates_acceptance_of-behavior-in-rails-20/
  validates_acceptance_of :contract_agreement, :accept => true, :allow_nil => false
  validates_inclusion_of :location, :in => LOCATIONS
end
