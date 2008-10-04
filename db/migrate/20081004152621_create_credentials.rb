class CreateCredentials < ActiveRecord::Migration
  def self.up
    create_table :credentials do |t|
      t.string :title, :url, :type
      t.text :description
      t.integer :user_id
      t.timestamps
    end
    
    add_index :credentials, :user_id
  end

  def self.down
    remove_index :credentials, :user_id
    drop_table :credentials
  end
end
