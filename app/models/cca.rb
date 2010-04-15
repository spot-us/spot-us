class Cca < ActiveRecord::Base
  validates_presence_of   :sponsor_id, :title
  belongs_to :user, :foreign_key => :sponsor_id
  has_many :cca_questions, :order => "position"
  has_many :cca_answers
  
  # status 
  # 0 = editing | 1 = live | 2 = maxed_out
    
  def number_of_answers
    cca_answers.any? ? cca_answers.count(:select=>"distinct user_id") : 0
  end

  def survey_completed?(user)
    completed_answer = self.cca_answers.find(:first, :conditions => "user_id = #{user.id} and status = 1")
    return false if completed_answer.blank?
    return true
  end
  
  def award_credit(user)
    Credit.create(:user_id => user.id, :amount => self.award_amount, 
                          :description => "Awarded for #{self.title} | #{self.id}")
    self.update_credits_awarded(self.award_amount)
    self.set_completed_status(user)
  end 
  
  def update_credits_awarded(amount)
    self.credits_awarded = self.credits_awarded + amount
    self.status = 2 if self.credits_awarded > self.max_credits_amount
    self.save!
  end
  
  def set_completed_status(user)
    self.cca_answers.update_all("status = 1", "user_id = #{user.id}" )
  end
  
  def is_editing?
    self.status == 0 ? true : false
  end
  
  def is_live?
    self.status == 1 ? true : false
  end

  def is_maxed_out?
    self.status == 2 ? true : false
  end
  
  def status?
    return "Pending" if is_editing?
    return "Live" if is_live?
    return "Finished" if is_maxed_out?
    return "Unknown"
  end
  
  def to_s
    title
  end
  
  def to_param
    begin 
      "#{id}-#{to_s.parameterize}"
    rescue
      "#{id}"
    end
  end
  
  def generate_csv
    FasterCSV.generate do |csv|
      csv << ['Question', 'Answers']
      cca_questions.each do |question|
        csv << [question.question, '', '']
        question.cca_answers.each do |answer|
          csv << ['',answer.user.full_name, answer.answer]
        end
      end
    end
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
