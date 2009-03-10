class ContributorApplication < ActiveRecord::Base
  belongs_to :user
  belongs_to :pitch

  validates_presence_of :user, :pitch
  validates_uniqueness_of :pitch_id, :scope => :user_id

  named_scope :for_pitch, lambda {|pitch| {:conditions => {:pitch_id => pitch.id} } }
end
