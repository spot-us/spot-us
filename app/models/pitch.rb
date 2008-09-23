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

class Pitch < ActiveRecord::Base
  has_attached_file :featured_image, :styles => { :thumb => '50x50#', :medium => "250x150#" }
end
