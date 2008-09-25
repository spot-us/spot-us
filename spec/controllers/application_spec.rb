require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do

  describe "with a logged in citizen" do
    before do
      controller.stub!(:logged_in?).and_return(true)
      user = User.find(Factory(:user, :type => 'Citizen').to_param)
      violated "user must be a citizen" unless Citizen === user
      controller.stub!(:current_user).and_return(user)
    end

    it "'start a story' should link to the new tip path" do
      controller.should_receive(:new_tip_path).and_return('new tip')
      controller.start_story_path.should == 'new tip'
    end
  end

  describe "with a logged in reporter" do
    before do
      controller.stub!(:logged_in?).and_return(true)
      user = User.find(Factory(:user, :type => 'Reporter').to_param)
      violated "user must be a reporter" unless Reporter === user
      controller.stub!(:current_user).and_return(user)
    end

    it "'start a story' should link to the new pitch path" do
      controller.should_receive(:new_pitch_path).and_return('new pitch')
      controller.start_story_path.should == 'new pitch'
    end
  end

  describe "with a guest user" do
    before do
      controller.stub!(:logged_in?).and_return(false)
      controller.stub!(:current_user).and_return(nil)
    end

    it "'start a story' should link to the new tip path" do
      controller.should_receive(:new_tip_path).and_return('new tip')
      controller.start_story_path.should == 'new tip'
    end
  end
end
