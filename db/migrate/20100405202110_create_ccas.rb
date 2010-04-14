class CreateCcas < ActiveRecord::Migration
  def self.up
     create_table :ccas do |t|
       t.integer :sponsor_id
       t.string :title
       t.string :description, :limit => 500
       t.integer :status, :limit => 2, :default => 0
       t.timestamps
     end
   end

   def self.down
     drop_table :ccas
   end
end
