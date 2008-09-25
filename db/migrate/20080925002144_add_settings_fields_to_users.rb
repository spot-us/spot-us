class AddSettingsFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :address1, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zip, :string
    add_column :users, :phone, :string
    add_column :users, :country, :string
  end

  def self.down
    remove_column :users, :country
    remove_column :users, :phone
    remove_column :users, :zip
    remove_column :users, :state
    remove_column :users, :city
    remove_column :users, :address2
    remove_column :users, :address1
  end
end
