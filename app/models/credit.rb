class Credit < ActiveRecord::Base
  belongs_to :user
  has_dollar_field :amount
  
  validates_presence_of :user_id, :description, :amount
end
