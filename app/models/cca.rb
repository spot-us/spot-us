class Cca < ActiveRecord::Base
  validates_presence_of   :sponsor_id, :title
  belongs_to :user, :foreign_key => :sponsor_id
  has_many :cca_questions
  has_many :cca_answers
end
