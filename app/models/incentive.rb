class Incentive < ActiveRecord::Base
  
  belongs_to :pitch
  
  INCENTIVES = ActiveSupport::OrderedHash.new 
  INCENTIVES[1] = 10
  INCENTIVES[2] = 50
  INCENTIVES[3] = 100
  INCENTIVES[4] = 150
  INCENTIVES[5] = 500
  
  validates_presence_of :incentive_id, :pitch, :description
  
  def level?
    "Donated XXX or more".gsub('XXX',"#{INCENTIVES[incentive_id]}".to_currency)
  end
  
  def validate
    p = Incentive.find(:first, :conditions => ["incentive_id=?", incentive_id])
    unless p
      errors.add('', 'You can only have one incentive per donation level')
      return false
    end
    return true
  end
  
end
