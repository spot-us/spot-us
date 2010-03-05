class AddCreditIdToSpotUsDonations < ActiveRecord::Migration
  def self.up
    add_column :spotus_donations, :credit_id, :integer
  end

  def self.down
    remove_column :spotus_donations, :credit_id
  end
end
