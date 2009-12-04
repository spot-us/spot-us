class AssignmentContributor < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :contributor, :class_name => "User", :foreign_key => "contributor_id"
  
  validates_presence_of :assignment, :contributor
  validates_uniqueness_of :assignment_id, :scope => :contributor_id, :message => "You have already applied to this assignment"
  
  def accept
    self.status = "accepted"
    if self.save!
      Mailer.deliver_assignment_application_accepted_notification(self.assignment,self.contributor)
      return true
    end
    return false
  end
  
  def reject
    self.status = "rejected"
    if self.save!
      Mailer.deliver_assignment_application_rejected_notification(self.assignment,self.contributor)
      return true
    end
    return false
  end
end