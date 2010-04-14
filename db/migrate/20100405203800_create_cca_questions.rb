class CreateCcaQuestions < ActiveRecord::Migration
  def self.up
     create_table :cca_questions do |t|
       t.integer :cca_id
       t.string :question
       t.string :question_data, :limit => 1000
       t.string :question_type # eg., checkboxes, select, textarea etc
       t.string :section
       t.boolean :required, :default => true
       t.integer :status, :limit => 2, :default => 0
       t.timestamps
     end
   end

   def self.down
     drop_table :cca_questions
   end
end
