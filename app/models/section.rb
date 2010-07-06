class Section < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :title
  validates_presence_of :extended_description

  def short
    if short_description.blank? 
      return extended_description.length>250 ? extended_description[0..250].gsub(/\w+$/, '')+"..." : extended_description
    else  
      return short_description
    end
  end

  def self.sections_include?(sections)
	all_sections = Section.all
	result = true
	sections.each do |section|
		has_sec = Section.all.map(&:name).include?(section)
		result = false if !has_sec
	end
	result
  end

end
