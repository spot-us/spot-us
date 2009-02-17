class SiteOption < ActiveRecord::Base
  include Sanitizy

  validates_presence_of :key
  validates_presence_of :value

  cleanse_columns(:value) do |sanitizer|
    sanitizer.allowed_tags.replace(%w(object param embed a img))
    sanitizer.allowed_attributes.replace(%w(width height name src value allowFullScreen type href allowScriptAccess style wmode pluginspage classid codebase data quality))
  end

  def self.for(key)
    site_option = find_by_key(key)
    site_option && site_option.value
  end
end
