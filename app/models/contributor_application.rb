class ContributorApplication < ActiveRecord::Base
  belongs_to :user
  belongs_to :pitch

  validates_presence_of :user, :pitch
  validates_uniqueness_of :pitch_id, :scope => :user_id
end
