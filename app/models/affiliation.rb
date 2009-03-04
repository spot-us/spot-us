class Affiliation < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :pitch
  belongs_to :tip
  validates_presence_of :tip_id
  validates_presence_of :pitch_id
  validates_uniqueness_of :pitch_id, :scope => :tip_id

  def createable_by?(user)
    return false unless user && pitch
    user && (pitch.user == user || user.admin?)
  end

  def editable_by?(user)
    false
  end
end


# == Schema Information
# Schema version: 20090116200734
#
# Table name: affiliations
#
#  id         :integer(4)      not null, primary key
#  tip_id     :integer(4)
#  pitch_id   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

