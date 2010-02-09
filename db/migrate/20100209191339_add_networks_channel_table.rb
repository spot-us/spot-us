class AddNetworksChannelTable < ActiveRecord::Migration
  def self.up
     create_table :channels_networks do |t|
       t.integer :channel_id
       t.integer :network_id
       t.timestamps
     end
   end

   def self.down
     drop_table :channels_networks
   end
end