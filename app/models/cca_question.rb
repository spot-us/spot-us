class CcaQuestion < ActiveRecord::Base
  belongs_to :cca
  has_many :cca_answers, :conditions => 'default_answer=0 OR default_answer is null'
  has_many :default_cca_answers, :class_name=>"CcaAnswer", :conditions => 'default_answer=1', :foreign_key => "cca_question_id"
  validates_presence_of   :cca_id, :question, :question_type, :position
  
  default_scope :order => "position asc"
  
  def self.QUESTION_TYPES
    ["text_small","text_big","radio","checkbox"]
  end
  
  def self.QUESTION_TYPE_DESCRIPTIONS
    "A single line textbox (short answer),A multi line textbox (longer answer),A radio button set (user selects an answer),A checkbox button set (user selects multiple answers)"
  end
  
  def answer_by_user(user, default_answer)
    default_answer ? CcaAnswer.find_by_cca_question_id_and_default_answer(self,default_answer) : CcaAnswer.find_by_cca_question_id_and_user_id(self,user.id)
  end
end