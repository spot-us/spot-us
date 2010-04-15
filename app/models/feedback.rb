class Feedback < ActiveRecord::Base
  validates_uniqueness_of :user_id, :scope => :feedback_type
  belongs_to :user
  def self.sponsor_interest(user)
    Feedback.create(:user_id => user.id, :feedback_type => "sponsor interest")
    Mailer.deliver_sponsor_interest_notification(user)  
  end
end
