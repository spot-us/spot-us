class CreateSpotusDonations < ActiveRecord::Migration
  def self.up
    create_table :spotus_donations do |t|
      t.integer :user_id
      t.integer :amount_in_cents
      t.integer :purchase_id
      t.timestamps
    end
  end

  def self.down
    drop_table :spotus_donations
  end
end
