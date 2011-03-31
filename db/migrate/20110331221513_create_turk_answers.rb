class CreateTurkAnswers < ActiveRecord::Migration
  def self.up
    create_table :turk_answers do |t|
      t.string        :turkable_type
      t.integer       :turkable_id
      t.integer       :cca_id
      t.integer       :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :turk_answers
  end
end
