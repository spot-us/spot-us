class CcaAnswer < ActiveRecord::Base
	belongs_to :user
	belongs_to :cca
	belongs_to :cca_question
	validates_uniqueness_of :user_id, :scope => [:cca_question_id, :default_answer]

	named_scope :latest_answer, lambda { |cca, user| {
		:conditions => "cca_id = #{cca.id} and user_id = #{user.id} and default_answer=0", :order => "updated_at desc"
	}}
end