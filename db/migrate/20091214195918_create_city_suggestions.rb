class CreateCitySuggestions < ActiveRecord::Migration
  def self.up
    create_table :city_suggestions do |t|
      t.string :city
      t.string :email
      t.timestamps
    end
  end

  def self.down
    drop_table :city_suggestions
  end
end
