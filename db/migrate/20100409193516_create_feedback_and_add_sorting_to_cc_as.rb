class CreateFeedbackAndAddSortingToCcAs < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.integer :user_id
      t.string :email
      t.string :feedback_type
      t.string :content
      t.integer :status, :limit => 2, :default => 0
      t.timestamps
    end
    add_column :ccas, :position, :integer, :default => 0
    add_column :cca_questions, :position, :integer, :default => 0
    add_column :cca_questions, :description, :string
    add_column :cca_questions, :default_value, :string
  end

  def self.down
    drop_table :feedbacks
    remove_column :ccas, :position
    remove_column :cca_questions, :position
    remove_column :cca_questions, :description
    remove_column :cca_questions, :default_value
  end
end
