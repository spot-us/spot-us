class Affiliation < ActiveRecord::Base
  belongs_to :pitch
  belongs_to :tip
  validates_presence_of :tip_id
  validates_presence_of :pitch_id
end

