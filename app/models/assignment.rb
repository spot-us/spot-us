class Assignment < ActiveRecord::Base
  belongs_to :pitch
  belongs_to :user

  validates_presence_of :title, :body, :user, :pitch
  has_many :assignment_contributors
  has_many :contributors, :through => :assignment_contributors, :source => :contributor, :foreign_key => :user_id
  
  # def blog_posted_notification
  #    Mailer.deliver_blog_posted_notification(self)
  #  end
end
