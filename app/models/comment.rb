class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  validates_presence_of :body
  validates_length_of :body, :maximum => 2000
  after_create :send_notification
  after_save :touch_commentable
  
  def send_notification
    (self.commentable.comment_subscribers - [self.user]).each do |commenter|
      Mailer.deliver_comment_notification(self, commenter)  if commenter.notify_comments && !BlacklistEmail.find_by_email(commenter.email)
    end
  end
  
  def touch_commentable
    item = self.commentable
    item.updated_at = Time.now
    item.save
  end
  
end

# == Schema Information
# Schema version: 20090116200734
#
# Table name: comments
#
#  id               :integer(4)      not null, primary key
#  title            :string(255)
#  commentable_type :string(255)
#  commentable_id   :integer(4)
#  user_id          :integer(4)
#  body             :text
#  created_at       :datetime
#  updated_at       :datetime
#

