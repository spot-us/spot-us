class AddDisplayNameToNetworks < ActiveRecord::Migration
  def self.up
    add_column :networks, :display_name, :string
  end

  def self.down
    remove_column :networks, :display_name
  end
end
