class Assignment < ActiveRecord::Base
  belongs_to :pitch
  belongs_to :user

  validates_presence_of :title, :body, :user, :pitch
  has_many :assignment_contributors, :dependent => :destroy
  has_many :applications, :class_name => "AssignmentContributor"
  has_many :contributors, :through => :assignment_contributors, :source => :contributor, :foreign_key => :user_id
  has_many :accepted_contributors, :through => :assignment_contributors, :source => :contributor, :foreign_key => :user_id,
           :conditions => "assignment_contributors.status = 'accepted'"
  has_many :rejected_contributors, :through => :assignment_contributors, :source => :contributor, :foreign_key => :user_id,
           :conditions => "assignment_contributors.status = 'rejected'"
  named_scope :open, :conditions => "status = 'open'"
  named_scope :closed, :conditions => "status = 'closed'"
  # def blog_posted_notification
  #    Mailer.deliver_blog_posted_notification(self)
  #  end
  
  def process_application(user)
    return false unless user
    return false if self.contributors.include?(user)
    self.contributors << user
    Mailer.deliver_assignment_application_notification(:assignment => self,:contributor => user)
    true
  end
  
  def is_closed?
    return true if self.status == "closed"
    return false
  end
  
  def open
    return false unless user
    self.status = "open"
    if self.save!
      true
    else
      false
    end
  end
  
  def close
    return false unless user
    self.status = "closed"
    if self.save!
      true
    else
      false
    end
  end
  
  def to_s
    title
  end
  
  def to_param
    "#{id}-#{to_s.parameterize}"
  end
  
end
