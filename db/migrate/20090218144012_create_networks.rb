class CreateNetworks < ActiveRecord::Migration
  def self.up
    create_table :networks do |t|
      t.string :name

      t.timestamps
    end

    Network.create!(:name => 'sfbay')
  end

  def self.down
    drop_table :networks
  end
end
