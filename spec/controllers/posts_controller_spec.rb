require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PostsController do

  describe "#authorized?" do
    it "should return nil with no current_user" do
      controller.stub!(:current_user).and_return(nil)
      controller.send(:authorized?).should be_nil
    end
    it "should return true if the current user is an admin" do
      controller.stub!(:current_user).and_return(Factory(:admin))
      controller.send(:authorized?).should be_true
    end
    it "should return true if the current user is the reporter for the pitch" do
      user = Factory(:user)
      pitch = Factory(:pitch, :user => user)
      controller.stub!(:resource).and_return(pitch)
      controller.stub!(:current_user).and_return(user)
      controller.send(:authorized?).should be_true
    end
    it "should return false if the current user is not the reporter or an admin" do
      controller.stub!(:resource).and_return(Factory(:pitch))
      controller.stub!(:current_user).and_return(Factory(:user))
      controller.send(:authorized?).should be_false
    end
  end
end
