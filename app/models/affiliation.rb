# == Schema Information
#
# Table name: affiliations
#
#  id         :integer(4)      not null, primary key
#  tip_id     :integer(4)      
#  pitch_id   :integer(4)      
#  created_at :datetime        
#  updated_at :datetime        
#

class Affiliation < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :pitch
  belongs_to :tip
  validates_presence_of :tip_id
  validates_presence_of :pitch_id

  def self.createable_by?(user)
    user and user.reporter?
  end

  def editable_by?(user)
    false
  end
end

