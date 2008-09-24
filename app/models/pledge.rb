class Pledge < ActiveRecord::Base
  belongs_to :user
  belongs_to :tip
  validates_presence_of :tip_id
  validates_presence_of :user_id
  validates_presence_of :amount

  has_dollar_field(:amount)
end

