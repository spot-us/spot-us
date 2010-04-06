class CcaAnswer < ActiveRecord::Base
  belongs_to :user
  belongs_to :cca
  belongs_to :cca_question
end