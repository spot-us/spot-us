class LoadDisplayNameForDefaultNetwork < ActiveRecord::Migration
  def self.up
    #Network.reset_column_information
    Network.create!(:name => 'sfbay', :display_name => 'Bay Area')
  end

  def self.down
  end
end
