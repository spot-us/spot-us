require File.dirname(__FILE__) + "/../../spec_helper"

describe 'news_items/index' do
  include NewsItemsHelper
  # 
  # before do
  #   @tip = Factory(:tip)
  #   @pitch = Factory(:pitch)
  #   @news_items = [@pitch, @tip]
  #   assigns[:news_items] = @news_items
  # end
  # 
  # it 'should render' do
  #   do_render
  # end
  # 
  # it "should have a link to each news item" do
  #   do_render
  #   template.should have_link_to(tip_path(@tip))
  #   template.should have_link_to(pitch_path(@pitch))
  # end
  # 
  # def do_render
  #   render "news_items/index"    
  # end
end
