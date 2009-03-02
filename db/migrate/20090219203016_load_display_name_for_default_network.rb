class LoadDisplayNameForDefaultNetwork < ActiveRecord::Migration
  def self.up
    Network.create!(:name => 'sfbay', :display_name => 'Bay Area')
  end

  def self.down
  end
end
