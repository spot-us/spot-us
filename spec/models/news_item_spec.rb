require File.dirname(__FILE__) + '/../spec_helper'

describe NewsItem do
  describe "to support STI" do
    table_has_columns(NewsItem, :string, :type)
  end

  table_has_columns(NewsItem, :string, "headline")
  table_has_columns(NewsItem, :string, "location")
  table_has_columns(NewsItem, :string, "keywords")
  table_has_columns(NewsItem, :string, "featured_image_caption")
  table_has_columns(NewsItem, :string, "video_embed")
  table_has_columns(NewsItem, :integer, "user_id")

  requires_presence_of NewsItem, :headline
  requires_presence_of NewsItem, :location
  requires_presence_of NewsItem, :user_id

  it { NewsItem.should belong_to(:user) }

  describe NewsItem do
    before(:each) do
      @news_item = Factory(:news_item, :user => Factory(:user))
    end

    it "is editable by its owner" do
      @news_item.editable_by?(@news_item.user).should be_true
    end

    it "is not editable by a stranger" do
      @news_item.editable_by?(Factory(:user)).should_not be_true
    end

    it "is not editable if not logged in" do
      @news_item.editable_by?(nil).should_not be_true
    end
  end

  describe "to support paperclip" do
    it "has a paperclip attachment for featured_image" do
      Factory(:news_item).featured_image.should be_instance_of(Paperclip::Attachment)
    end

    table_has_columns(NewsItem, :string, :featured_image_file_name)
    table_has_columns(NewsItem, :string, :featured_image_content_type)
    table_has_columns(NewsItem, :integer, :featured_image_file_size)
    table_has_columns(NewsItem, :datetime, :featured_image_updated_at)
  end

  describe "newest news items" do
    before do
      @items = [Factory(:news_item), Factory(:news_item), Factory(:news_item)]
      @items.reverse.each_with_index do |item, i|
        NewsItem.update_all("created_at = '#{i.days.ago.to_s(:db)}'", "id=#{item.id}")
      end
      @items.each(&:reload)
      unless @items.collect(&:created_at).uniq.size == 3
        violated "need 3 different created_at values to test sorting"
      end

      @result = NewsItem.newest
    end

    it "should return items in reverse created at order" do
      @result.should == @result.sort {|b, a| a.created_at <=> b.created_at }
    end

    it "should return all items" do
      @result.size.should == @items.size
    end
  end
end

