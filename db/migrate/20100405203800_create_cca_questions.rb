class CreateCcaQuestions < ActiveRecord::Migration
  def self.up
     create_table :cca_questions do |t|
       t.integer :cca_id
       t.string :name
       t.string :question
       t.string :question_type # eg., checkboxes, select, textarea etc
       t.string :section
       t.integer :status, :limit => 2
       t.timestamps
     end
   end

   def self.down
     drop_table :cca_questions
   end
end
