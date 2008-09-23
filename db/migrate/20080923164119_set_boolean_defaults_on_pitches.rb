class SetBooleanDefaultsOnPitches < ActiveRecord::Migration
  def self.up
    change_table :pitches do |t|
      t.change "deliver_text", :boolean, :default => false, :null => false
      t.change "deliver_audio", :boolean, :default => false, :null => false
      t.change "deliver_video", :boolean, :default => false, :null => false
      t.change "deliver_photo", :boolean, :default => false, :null => false
      t.change "contract_agreement", :boolean, :default => false, :null => false
    end
  end

  def self.down
    change_table :pitches do |t|
      t.change "deliver_text", :boolean, :default => nil, :null => true
      t.change "deliver_audio", :boolean, :default => nil, :null => true
      t.change "deliver_video", :boolean, :default => nil, :null => true
      t.change "deliver_photo", :boolean, :default => nil, :null => true
      t.change "contract_agreement", :boolean, :default => nil, :null => true
    end
  end
end
