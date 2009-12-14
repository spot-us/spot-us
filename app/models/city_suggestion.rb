class CitySuggestion < ActiveRecord::Base
  validates_presence_of :email, :city
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :city, :scope => :email, :message => "You have already suggested this city."
end