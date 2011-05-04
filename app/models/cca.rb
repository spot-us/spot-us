class Cca < ActiveRecord::Base
  validates_presence_of   :sponsor_id, :title
  validate :check_credit_settings, :on => [:update, :new]
  belongs_to :user, :foreign_key => :sponsor_id
  has_many :cca_questions, :order => "position"
  has_many :cca_answers, :conditions => 'cca_answers.default_answer=0 OR cca_answers.default_answer is null'
  has_many :default_cca_answers, :class_name=>"CcaAnswer", :conditions => 'cca_answers.default_answer=1', :foreign_key => "cca_id"
  has_many :credits, :foreign_key=>'cca_id'
  has_many :pictures
  has_many :turk_answers
  
  after_create :assign_pictures, :if=>:is_picture_task
  
  attr_accessor :providing_default_answer
  @@providing_default_answer = false

  has_attached_file :banner,
    :styles => { :thumb => '99x78#', 
      :large_banner => "992x78#", 
      :small_banner => "496x39#"},
      :storage => :s3,
      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
      :bucket =>   S3_BUCKET,
      :path => "cca-banners/" <<
      ":attachment/:id_partition/" <<
      ":basename_:style.:extension",
      :url =>  "cca-banners/:attachment/:id_partition/" <<
      ":basename_:style.:extension"

    unless Rails.env.development?
      validates_attachment_content_type :banner,
      :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png',
        'image/x-png', 'image/jpg'],
        :message      => "Oops! Make sure you are uploading an image file.",
        :unless => :banner_name

        validates_attachment_size :banner, :in => 1..5.megabytes, :unless => :banner_name
    end

  named_scope :cca_home, :conditions=>'status=1', :order => 'RAND()'
  named_scope :live, :conditions=>'status=1', :order => 'position asc, created_at desc'

  STATUS_VALUES = ["Pending", "Live", "Finished"]
  TOTAL_TURKS_VALUES = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
  TURKS_PER_USER = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

  def banner_name
    banner_file_name.blank?
  end

  def get_answers_by_user(user_id)
    turk_answers.find(:all, :conditions => ["user_id=?", user_id])
  end

  def has_begun?(user)
    return false unless user
    CcaAnswer.find_by_user_id_and_cca_id(user.id, self.id)
  end

  def number_of_answers
    cca_answers.any? ? cca_answers.count(:select=>"distinct user_id").to_i : 0
  end

  def sections
    cca_questions.all(:select=>"distinct section", :conditions=>'section is not null and section!=""').map(&:section).compact
  end

  def check_credit_settings
    if self.award_amount > self.max_credits_amount && !is_picture_task
      errors.add_to_base("Award amount cannot be greater than maximum credit amount")
    end
  end

  def survey_completed?(user)
    return false unless user
    # checks if user has completed this survey
    return true if self.get_answers_by_user(user.id).length>5
    completed_answer = self.cca_answers.find(:first, :conditions => "user_id = #{user.id} and status = 1")
    return false if completed_answer.blank?
    return true
  end

  def award_credit(user)
    Credit.create(:user_id => user.id, :amount => self.award_amount, 
      :description => "Awarded for #{self.title} | #{self.id}", :cca_id=>self.id)
    self.process_credits_awarded(self.award_amount)
    self.set_completed_status(user)
  end 

  def process_credits_awarded(amount)
    self.credits_awarded = self.credits_awarded + amount
    self.status = 2 if self.credits_awarded > self.max_credits_amount
    self.save!
  end

  def set_completed_status(user)
    # cca_answers status is completed when user has answered all required questions
    self.cca_answers.update_all("status = 1", "user_id = #{user.id}" )
  end

  def is_pending?
    self.status == 0 ? true : false
  end

  def is_live?
    self.status == 1 ? true : false
  end

  def is_maxed_out?
    self.status == 2 ? true : false
  end

  def status?
    return "Pending" if is_pending?
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
      csv << ['Question', 'User', 'Answers']
      cca_questions.each do |question|
        csv << [question.question, '', '']
        question.cca_answers.each do |answer|
          csv << ['',(answer.user ? answer.user.full_name : "deleted user"), answer.answer] if self.survey_completed?(answer.user)
        end
        if question.question_type=='radio' || question.question_type=='radio_horizontal' || question.question_type=='checkbox'
          csv << ['', '', '']
          csv << [question.question, 'Answer', 'Nr Of Answers']
          answers = question.cca_answers.find(:all, :group => 'answer', :select => 'answer, count(*) as nr_of_answers')
          not_finished_arr = {}
          answers.each do |a|
            not_finished_arr[a.answer] = 0
          end
          question.cca_answers.each do |a|
            not_finished_arr[a.answer] += 1 unless self.survey_completed?(a.user)
          end
          total_answers_count = 0
          answers.each do |answer|
            csv << ['', answer.answer, answer.nr_of_answers.to_i-not_finished_arr[answer.answer]]
            total_answers_count += (answer.nr_of_answers.to_i-not_finished_arr[answer.answer]) 
          end
          csv << ['', 'Total Answers', total_answers_count]
        end
        csv << ['', '', '']
      end
    end
  end
  
  def generate_csv_file(file_name="results.csv")
    FasterCSV.open("/data/spotus/"+file_name,"w") do |csv|
      csv << ['Question', 'User', 'Answers']
      cca_questions.each do |question|
        csv << [question.question, '', '']
        question.cca_answers.each do |answer|
          csv << ['',(answer.user ? answer.user.full_name : "deleted user"), answer.answer] if self.survey_completed?(answer.user)
        end
        if question.question_type=='radio' || question.question_type=='radio_horizontal' || question.question_type=='checkbox'
          csv << ['', '', '']
          csv << [question.question, 'Answer', 'Nr Of Answers']
          answers = question.cca_answers.find(:all, :group => 'answer', :select => 'answer, count(*) as nr_of_answers')
          not_finished_arr = {}
          answers.each do |a|
            not_finished_arr[a.answer] = 0
          end
          question.cca_answers.each do |a|
            not_finished_arr[a.answer] += 1 unless self.survey_completed?(a.user)
          end
          total_answers_count = 0
          answers.each do |answer|
            csv << ['', answer.answer, answer.nr_of_answers.to_i-not_finished_arr[answer.answer]]
            total_answers_count += (answer.nr_of_answers.to_i-not_finished_arr[answer.answer]) 
          end
          csv << ['', 'Total Answers', total_answers_count]
        end
        csv << ['', '', '']
      end
    end
  end

  def process_answers(answers, user, pitch_id)
    form_incomplete = false
    self.cca_questions.each do |question|
      answer_incomplete = false
      answer = eval("answers[:question_#{question.id}]") || nil
      if question.question_type == "checkbox"
        answer_incomplete = true if !answer || answer.size == 0
      else
        answer_incomplete = true if !answer || answer.strip == ""
      end
      form_incomplete = true if answer_incomplete and question.required == true 
      # insert/update db for items that are completed
      if answer_incomplete == false
        answer = answer.join("\n") if question.question_type == "checkbox"
        existing_answer = CcaAnswer.find_by_cca_question_id_and_user_id_and_default_answer(question.id,user.id,providing_default_answer)
        if existing_answer
          CcaAnswer.update(existing_answer.id, :answer => answer, :pitch_id => pitch_id, :default_answer=>providing_default_answer)
        else
          CcaAnswer.create(:cca_id => self.id, :user_id => user.id, :cca_question_id => question.id, :answer => answer, :pitch_id => pitch_id, :default_answer=>providing_default_answer)
        end
      end
    end
    # return whether form is finished or user needs to still fill out elements
    !form_incomplete
  end

  def already_submitted?(user)
    answer = CcaAnswer.find_by_user_id_and_cca_id_and_status_and_default_answer(user,self.id,1,false)
    answer ? true : false
  end
  
  def assign_pictures
    if is_picture_task
      Picture.find(:all, :conditions => 'cca_id is null', :limit => total_turks).each do |p|
        p.update_attributes({:cca_id => id})
      end
    end
  end

end
