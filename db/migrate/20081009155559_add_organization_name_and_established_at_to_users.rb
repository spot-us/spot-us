class AddOrganizationNameAndEstablishedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column  :users, :organization_name, :string
    add_column  :users, :established_year, :string
  end

  def self.down
    remove_column  :users, :organization_name
    remove_column  :users, :established_year
  end
end
