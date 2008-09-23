class CreateDonation < ActiveRecord::Migration
  def self.up
    create_table :donations do |t|
      t.belongs_to :user
      t.belongs_to :pitch
      t.timestamps
    end
    add_index :donations, :user_id
    add_index :donations, :pitch_id
  end

  def self.down
    drop_table :donations
  end
end
