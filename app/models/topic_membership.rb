# == Schema Information
#
# Table name: topic_memberships
#
#  id          :integer(4)      not null, primary key
#  member_id   :integer(4)      
#  member_type :string(255)     
#  topic_id    :integer(4)      
#  created_at  :datetime        
#  updated_at  :datetime        
#

class TopicMembership < ActiveRecord::Base
  belongs_to :topic
  belongs_to :member, :polymorphic => true
end
