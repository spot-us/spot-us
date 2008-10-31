require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NewsItemsHelper do
  it "should return true on checkbox for tips when doing sorting" do
    params[:controller] = 'news_items'
    params[:news_item_types] = {:tip => "1"}
    check_box_checked_for?(:tip).should be_true
  end
  
  it "should return true on checkbox for tips when doing search without sorting" do
    params[:controller] = 'news_items'
    params[:news_item_types] = {:tip => "1"}
    check_box_checked_for?(:tip).should be_true
  end
  
  it "should return false for tips when retrieving /index with no sorting and not checked" do
    params[:controller] = 'news_items'
    check_box_checked_for?(:tip).should be_false
  end

end
