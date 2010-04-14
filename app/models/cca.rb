class Cca < ActiveRecord::Base
  validates_presence_of   :sponsor_id, :title
  belongs_to :user, :foreign_key => :sponsor_id
  has_many :cca_questions, :order => "position"
  has_many :cca_answers
  
  def self.DEFAULT_CREDIT_AMOUNT
    5
  end
    
  def survey_completed?(user)
    completed_answer = self.cca_answers.find(:first, :conditions => "user_id = #{user.id} and status = 1")
    return false if completed_answer.blank?
    return true
  end
  
  def award_credit(user)
    Credit.create(:user_id => user.id, :amount => Cca.DEFAULT_CREDIT_AMOUNT, :description => "Awarded for #{self.title} | #{self.id}")
    self.set_completed_status(user)
  end 
  
  def set_completed_status(user)
    self.cca_answers.update_all("status = 1", "user_id = #{user.id}" )
  end
  
  def is_live?
    self.status == 1 ? true : false
  end
  
  def process_answers(answers, user)
    incomplete = false
    self.cca_questions.each do |question|
      answer = eval("answers[:question_#{question.id}]") || nil
      if question.required == true && (!answer || answer.strip == "")
        #debugger
        incomplete = true
      else
        existing_answer = CcaAnswer.find_by_cca_question_id_and_user_id(question.id,user.id)
        if existing_answer
          CcaAnswer.update(existing_answer.id, :answer => answer)
        else
          CcaAnswer.create(:cca_id => self.id, :user_id => user.id, :cca_question_id => question.id, :answer => answer)
        end
      end
    end
    !incomplete
  end
    
end
