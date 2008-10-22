class CreateStatusColumnOnDonation < ActiveRecord::Migration
  def self.up
    add_column :donations, :status, :string, :default => 'unpaid'
  end

  def self.down
    remove_column :donations, :status
  end
end
