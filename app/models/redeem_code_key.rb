class RedeemCodeKey < ActiveRecord::Base
  
  has_many :credits
  
  def credits_left?
    cap - credits.count > 0
  end
  
end
