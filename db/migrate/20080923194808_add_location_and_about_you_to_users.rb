class AddLocationAndAboutYouToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :location, :string
    add_column :users, :about_you, :text
  end

  def self.down
    remove_column :users, :about_you
    remove_column :users, :location
  end
end
