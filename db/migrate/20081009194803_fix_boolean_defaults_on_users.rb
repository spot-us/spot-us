class FixBooleanDefaultsOnUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change :notify_tips,        :boolean, :default => false, :null => false
      t.change :notify_pitches,     :boolean, :default => false, :null => false
      t.change :notify_stories,     :boolean, :default => false, :null => false
      t.change :notify_spotus_news, :boolean, :default => false, :null => false
    end
  end

  def self.down
  end
end
