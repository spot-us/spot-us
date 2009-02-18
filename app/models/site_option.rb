# == Schema Information
# Schema version: 20090218144012
#
# Table name: site_options
#
#  id         :integer(4)      not null, primary key
#  key        :string(255)
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#

class SiteOption < ActiveRecord::Base
  validates_presence_of :key
  validates_presence_of :value

  def self.for(key)
    site_option = find_by_key(key)
    site_option && site_option.value
  end
end
