class AddDisplayNameToNetworks < ActiveRecord::Migration
  def self.up
    add_column :networks, :display_name, :string

    Network.find_by_name('sfbay').update_attribute(:display_name, 'Bay Area')
  end

  def self.down
    remove_column :networks, :display_name
  end
end
