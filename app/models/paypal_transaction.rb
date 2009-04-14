class PaypalTransaction < ActiveRecord::Base
  validates_presence_of :txn_id
end
