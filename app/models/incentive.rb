class Incentive < ActiveRecord::Base
  
  belongs_to :pitch
    
  validates_presence_of :amount, :pitch, :description
  
  def level?
    "Donate XXX or more".gsub('XXX',"#{amount}".to_currency)
  end
  
  def validate
    p = nil
    p = Incentive.find(:first, :conditions => ["amount=? and pitch_id=?", amount, pitch.id]) if pitch
    if p
      errors.add('', 'You can only have one incentive per amount level')
      return false
    end
    return true
  end
  
end
