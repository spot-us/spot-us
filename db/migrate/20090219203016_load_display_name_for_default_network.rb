class LoadDisplayNameForDefaultNetwork < ActiveRecord::Migration
  def self.up
    Network.find_by_name('sfbay').update_attribute(:display_name, 'Bay Area')
  end

  def self.down
    Network.find_by_name('sfbay').update_attribute(:display_name, '')
  end
end
