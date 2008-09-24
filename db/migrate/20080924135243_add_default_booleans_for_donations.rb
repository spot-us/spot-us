class AddDefaultBooleansForDonations < ActiveRecord::Migration
  def self.up
    change_column :donations, :paid, :boolean, :default => false, :null => false
  end

  def self.down
    change_column :donations, :paid, :boolean, :default => nil, :null => true
  end
end
