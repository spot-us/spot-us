class Topic < ActiveRecord::Base
  validates_presence_of   :name
  validates_uniqueness_of :name
  has_many :topic_memberships
end

# == Schema Information
# Schema version: 20090116200734
#
# Table name: topics
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

