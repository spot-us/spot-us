class Network < ActiveRecord::Base
  validates_presence_of :name
  validates_format_of   :name, :with => /^[a-z0-9|-]+$/i
end
