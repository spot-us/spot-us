class GroupingsUser < ActiveRecord::Base
  
  belongs_to :grouping
  belongs_to :user
  
end
