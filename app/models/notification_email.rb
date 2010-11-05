class NotificationEmail < ActiveRecord::Base
  
  validates_presence_of :subject, :body
  
  STATUS = {
      0 => 'Draft',
      1 => 'Marked To Send',
      2 => 'Sent'
    }
    
  LISTS = {
    "Active Reporters" => 0,
    "Users With Unused Credits" => 1,
    "Approved News Organizations" => 2
  }
  
  named_scope :to_send, :conditions => 'status=1'
  
  def users?
    return Pitch.all_active_reporters if list_id == 0
    return Credit.users_with_unused_credits if list_id == 1
    return Organization.approved.all if list_id == 2
  end
  
  def status?
    return STATUS[status] if STATUS[status]
    "Unknown status"
  end
  
  def draft?
    status==0
  end
  
  def not_sent?
    status==1
  end
  
  def sent?
    status==0
  end
  
end
