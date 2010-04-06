class CreateCcaAnswers < ActiveRecord::Migration
  def self.up
     create_table :cca_answers do |t|
       t.integer :cca_id
       t.integer :user_id
       t.integer :cca_question_id
       t.string :answer
       t.integer :status, :limit => 2
       t.timestamps
     end
  end

  def self.down
    drop_table :cca_answers
  end
end
