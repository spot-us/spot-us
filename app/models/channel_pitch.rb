class ChannelPitch < ActiveRecord::Base
  belongs_to :channel
  belongs_to :pitch

  validates_presence_of :channel, :pitch
  validates_uniqueness_of :pitch_id, :scope => :channel_id
end
