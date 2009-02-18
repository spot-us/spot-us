class LoadCategories < ActiveRecord::Migration
  def self.up
    ["San Francisco", "North Bay", "Peninsula", "East Bay", "South Bay"].each do |location|
      Category.create!(:network => Network.find_by_name('sfbay'), :name => location)
    end
  end

  def self.down
    Category.destroy_all
  end
end
