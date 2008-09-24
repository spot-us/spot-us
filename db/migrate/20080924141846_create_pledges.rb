class CreatePledges < ActiveRecord::Migration
  def self.up
    create_table :pledges do |t|
      t.belongs_to :user
      t.belongs_to :tip
      t.integer :amount_in_cents
      t.timestamps
    end

    add_index :pledges, :user_id
    add_index :pledges, :tip_id
  end

  def self.down
    remove_index :pledges, :column => :tip_id
    remove_index :pledges, :column => :user_id

    drop_table :pledges
  end
end
