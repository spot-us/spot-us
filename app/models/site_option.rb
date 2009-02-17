class SiteOption < ActiveRecord::Base
  validates_presence_of :key
  validates_presence_of :value

  def self.for(key)
    site_option = find_by_key(key)
    site_option && site_option.value
  end
end
