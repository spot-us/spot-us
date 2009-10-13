class Post < ActiveRecord::Base
  belongs_to :pitch
  belongs_to :user

  validates_presence_of :title, :body, :user, :pitch
  
  def blog_posted_notification
    Mailer.deliver_blog_posted_notification(self)
  end
end
