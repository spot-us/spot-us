require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::CreditsController do
  describe "get to index" do
    it "should supply list of credits in descending order" do
      controller.should_receive(:admin_required).and_return(true)
      get :index
      assigns[:users].should_not be_nil
      assigns[:credits].should_not be_nil
    end
  end
end