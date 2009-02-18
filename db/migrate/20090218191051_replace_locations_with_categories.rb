class ReplaceLocationsWithCategories < ActiveRecord::Migration
  def self.up
    # please don't hate my beautiful migration :(
    # We have created networks and categories to allow the app to expand to other areas.  Previously, location was tracked
    # as a string, but now we want to track this stuff based on networks and categories.
    # We will now attempt to transfer this data and remove the location column
    affected_models = [NewsItem, User]
    locations = ["Bay Area", "San Francisco", "North Bay", "Peninsula", "East Bay", "South Bay"]

    # add our new columns
    affected_models.each do |model|
      table_name = get_table_name(model)
      add_column table_name, :network_id, :integer
      add_column table_name, :category_id, :integer
    end

    # find the default network
    @network = Network.find_by_name('sfbay')

    # assign networks and categories based on previous location data
    locations.each do |location|
      category = Category.find_by_name(location)
      affected_models.each do |model|
        model.find_all_by_location(location).each do |instance|
          instance.network_id = @network.id
          instance.category_id = category.id if category
          instance.save
        end
      end
    end

    # dump the location field
    affected_models.each do |model|
      remove_column get_table_name(model), :location
    end
  end

  def self.get_table_name(model)
    model.class_name.tableize.to_sym
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
