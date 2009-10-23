class AddTypeToDonations < ActiveRecord::Migration
  def self.up
      add_column :donations, :donation_type, :string, :default => "payment"
      add_column :donations, :credit_id, :integer
      drop_table :credit_pitches
  end

  def self.down
      remove_column :donations, :donation_type
      remove_column :donations, :credit_id
  end
end
