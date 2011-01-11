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
  
  CCA_OFFSET = 50
  
  named_scope :to_send, :conditions => 'status=1'
  
  def users?
    return Pitch.all_active_reporters.compact if list_id == 0
    return Credit.users_with_unused_credits.compact if list_id == 1
    return Organization.approved.all.compact if list_id == 2
    return Cca.find_by_id(list_id-CCA_OFFSET).cca_answers.find(:all, :group => "user_id").map(&:user).compact if list_id > CCA_OFFSET
  end
  
  def self.lists?
    arr = []
    tmp = Cca.all.map{ |cca| arr << [cca.title, cca.id+CCA_OFFSET] }
    return NotificationEmail::LISTS.collect {|key, l| [key, l]}.concat(arr)
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
    status==2
  end
  
end
