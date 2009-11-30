class CreateSubscribers < ActiveRecord::Migration
  def self.up
    create_table :subscribers do |t|
      t.integer :pitch_id
      t.string :email
      t.string :status, :default => "requested"
      t.string :invite_token
      t.timestamps
    end
    add_index :subscribers, :pitch_id
  end

  def self.down
    drop_table :subscribers
  end
end
