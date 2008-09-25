require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do
  include ActionController::UrlWriter

  before do
    ApplicationController.send(:include, ActionController::UrlWriter)
  end

  describe "with a logged in citizen" do
    before do
      controller.stub!(:logged_in?).and_return(true)
      controller.stub!(:current_user).and_return(Factory(:user, :type => 'Citizen'))
    end

    it "'start a story' should link to the new tip path" do
      controller.start_story_path.should == new_tip_path
    end
  end

  describe "with a logged in reporter" do
    before do
      controller.stub!(:logged_in?).and_return(true)
      controller.stub!(:current_user).and_return(Factory(:user, :type => 'Reporter'))
    end

    it "'start a story' should link to the new pitch path" do
      controller.start_story_path.should == new_pitch_path
    end
  end

  describe "with a guest user" do
    before do
      controller.stub!(:logged_in?).and_return(false)
      controller.stub!(:current_user).and_return(nil)
    end

    it "'start a story' should link to the new tip path" do
      controller.start_story_path.should == new_tip_path
    end
  end
end
