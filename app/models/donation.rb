class Donation < ActiveRecord::Base
  belongs_to :user
  belongs_to :pitch
  validates_presence_of :pitch_id
  validates_presence_of :user_id
end

