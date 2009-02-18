class Category < ActiveRecord::Base
  validates_presence_of   :name
  validates_uniqueness_of :name, :scope => :network_id

  belongs_to :network
end
