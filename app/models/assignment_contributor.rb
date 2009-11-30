class AssignmentContributor < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :contributor, :class_name => "User", :foreign_key => "contributor_id"
  
  validates_presence_of :assignment, :contributor
  validates_uniqueness_of :assignment_id, :scope => :contributor_id
end