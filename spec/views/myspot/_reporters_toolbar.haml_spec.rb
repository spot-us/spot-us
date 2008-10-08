require File.dirname(__FILE__) + "/../../spec_helper"

describe 'myspot/_reporters_toolbar.html.haml' do
  before do
    @user = Factory(:user)
    template.stub!(:current_user).and_return(@user)
  end
  
  describe "when on a tip" do    
    it "should have a list of pitches for attaching to a tip" do
      pitch1 = Factory(:pitch, :headline => "Happy 1")
      pitch2 = Factory(:pitch, :headline => "Happy 2")
      items = [pitch1, pitch2]
      tip = mock(:tip)
      @user.should_receive(:pitches).at_least(1).with().and_return(items)
      tip.should_receive(:pitches).at_least(1).and_return(items)
      items.should_receive(:include?).at_least(1).and_return(false)
      render 'myspot/_reporters_toolbar.haml', :locals => {:tip => tip}
    end
  end

end
