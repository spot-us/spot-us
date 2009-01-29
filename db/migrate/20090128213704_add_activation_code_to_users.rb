class AddActivationCodeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :activation_code, :string
  end

  def self.down
    remove_column :users, :activation_code
  end
end
