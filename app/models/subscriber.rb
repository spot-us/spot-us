class Subscriber < ActiveRecord::Base
  validates_presence_of   :email
  validates_uniqueness_of :email, :scope => [:pitch_id]
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  belongs_to :pitch
  before_create :assign_invite_token
  after_create :send_subscription_email
  
  def subscribe
    self.status = "subscribed"
    self.save!
  end
  
  def cancel
    self.status = "canceled"
    self.save!
  end
  
  protected
  
  def assign_invite_token
     self.invite_token = rand(36**12).to_s(36)
  end
  
  def send_subscription_email
    Mailer.deliver_confirm_subscription(self)
  end

end
