class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.integer :user_id
      t.integer :pitch_id
      t.string :title
      t.text :body, :media_embed
      t.string :status, :default => "open"
      t.timestamps
    end
    add_index :assignments, :user_id
    add_index :assignments, :pitch_id
  end

  def self.down
    drop_table :assignments
  end
end
