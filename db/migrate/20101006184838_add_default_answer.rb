class AddDefaultAnswer < ActiveRecord::Migration
  def self.up
    add_column :cca_answers, :default_answer, :boolean, :default=>false
  end

  def self.down
    remove_column :cca_answers, :default_answer
  end
end
