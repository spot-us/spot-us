class CcaQuestion < ActiveRecord::Base
  belongs_to :cca
  has_many :cca_answers
end