class AddSeoNameToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :seo_name, :string
    Topic.all.each do |topic|
        topic.update_attributes({:seo_name => topic.name.parameterize.to_s})
    end
    Topic.create({:name => 'Los Angeles'})
    t = Topic.first
    t.seo_name = t.seo_name.gsub('+-', '')
    t.save
  end

  def self.down
    remove_column :topics, :seo_name
  end
end
