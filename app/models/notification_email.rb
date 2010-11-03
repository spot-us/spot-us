class NotificationEmail < ActiveRecord::Base
  
  validates_presence_of :subject, :body
  
  STATUS = {
      0 => 'Draft',
      1 => 'Marked To Send',
      2 => 'Sent'
    }
  
  named_scope :to_send, :conditions => 'status=1'
  
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
