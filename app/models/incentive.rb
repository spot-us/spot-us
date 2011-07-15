class Incentive < ActiveRecord::Base
  
  belongs_to :pitch
    
  validates_presence_of :amount, :pitch, :description
  validates_numericality_of :amount, :message => "You can only specify the incentive amount as numerical number. Do not use the $ sign when you specify the amount."
  validate_on_create :check_if_amount_is_uniq
  
  def level?
    "Donate XXX or more".gsub('XXX',"#{amount}".to_currency)
  end
  
  def check_if_amount_is_uniq
    p = nil
    p = Incentive.find(:first, :conditions => ["amount=? and pitch_id=?", amount, pitch.id]) if pitch
    if p
      errors.add('', 'You can only have one incentive per amount level')
      return false
    end
    return true
  end
  
end
