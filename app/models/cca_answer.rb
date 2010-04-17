class CcaAnswer < ActiveRecord::Base
  belongs_to :user
  belongs_to :cca
  belongs_to :cca_question
  validates_uniqueness_of :user_id, :scope => :cca_question_id
end