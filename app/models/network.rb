# == Schema Information
# Schema version: 20090218144012
#
# Table name: networks
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Network < ActiveRecord::Base
  validates_presence_of :name, :display_name
  validates_format_of   :name, :with => /^[a-z0-9|-]+$/i

  has_many :categories, :attributes => true, :discard_if => Proc.new {|category| category.name.blank? }
  has_many :pitches

  def self.with_pitches
    all(:conditions => "id in (select distinct network_id from news_items where type = 'pitch' and deleted_at IS NULL)")
  end
end
