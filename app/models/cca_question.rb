class CcaQuestion < ActiveRecord::Base
  belongs_to :cca
  has_many :cca_answers
  validates_presence_of   :cca_id, :question, :question_type, :position
  
  default_scope :order => "position asc"
  
  def self.QUESTION_TYPES
    ["text_small","text_big","radio","checkbox"]
  end
  
  def self.QUESTION_TYPE_DESCRIPTIONS
    "A single line textbox (short answer),A multi line textbox (longer answer),A radio button set (select an answer),A checkbox button set (select multiple answers)"
  end
  
  def answer_by_user(user)
    CcaAnswer.find_by_cca_question_id_and_user_id(self,user)
  end
end